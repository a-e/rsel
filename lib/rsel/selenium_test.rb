#require File.join(File.dirname(__FILE__), 'exceptions')

require 'rubygems'
require 'xpath'
require 'selenium/webdriver'

require 'rsel/support'
require 'rsel/exceptions'
require 'rsel/study_html'

module Rsel

  # Main Selenium-test class, and wrapper for all Selenium method calls. This
  # class is intended to be instantiated in a FitNesse / Slim script table.
  # May be customized or extended using a subclass.
  #
  # @note: Function names beginning with the words 'check', 'ensure', 'reject',
  # 'note', 'show', or 'start' cannot be called from a Slim script table, since
  # these are keywords that receive special handling by Slim.
  #
  # @example
  #   !| script | selenium test | http://www.example.com/ |
  #   | script | selenium test | !-http://www.example.com/-! |
  #
  class SeleniumTest

    include Support

    # Initialize a test, connecting to the given Selenium server.
    #
    # @param [String] url
    #   Full URL, including http://, of the system under test. Any
    #   HTML tags around the URL will be stripped.
    # @param [Hash] options
    #   Additional configuration settings
    #
    # @option options [String] :host
    #   IP address or hostname where selenium-server is running
    # @option options [String] :port
    #   Port number of selenium-server
    # @option options [String] :browser
    #   Which browser to run. Should be a string like `'*firefox'` (default),
    #   `'*googlechrome'`, `'*opera'`, `'*iexplore'`, `'*safari'` etc.
    # @option options [String, Boolean] :stop_on_failure
    #   `true` or `'true'` to abort the test when a failure occurs;
    #   `false` or `'false'` to continue execution when failure occurs.
    # @option options [String, Integer] :study
    #   How many steps have to be done at once to force studying.  Default
    #   is 10 for most browsers and 1 for Internet Explorer.  Other accepted
    #   strings are `Never' (0), `Always' (1), or an integer.  Unrecognized
    #   strings result in the default.
    # @option options [String, Integer] :timeout
    #   Default timeout in seconds. This determines how long the `open` method
    #   will wait for the page to load.
    #
    # @example
    #   | script | selenium test | http://site.to.test/ |
    #   | script | selenium test | http://site.to.test/ | !{host:192.168.0.3} |
    #   | script | selenium test | http://site.to.test/ | !{host:192.168.0.3, port:4445} |
    #   | script | selenium test | http://site.to.test/ | !{stop_on_failure:true} |
    #
    def initialize(url, options={})
      # Strip HTML tags from URL
      @url = strip_tags(url)
      @host = options[:host] || 'localhost'
      @port = options[:port] || 4444

      # Use WebDriver-backed Selenium
      @browser = Selenium::Client::Driver.new(
        :host => @host,
        :port => @port,
        :browser => '*webdriver',
        :url => @url,
        :default_timeout_in_seconds => options[:timeout] || 300)
      @driver = Selenium::WebDriver.for :remote,
        :url => "http://#{@host}:#{@port}/wd/hub"

      # Accept Booleans or strings, case-insensitive
      if options[:stop_on_failure].to_s =~ /true/i
        @stop_on_failure = true
      else
        @stop_on_failure = false
      end
      @found_failure = false
      @conditional_stack = [ true ]
      # Study data
      @study = StudyHtml.new()
      # @fields_study_min: The minimum number of fields to set_fields or fields_equal at once before studying is invoked.
      if @browser.browser_string == '*iexplore'
        @default_fields_study_min = 1
      else
        @default_fields_study_min = 10
      end
      @fields_study_min = parse_fields_study_min(options[:study], @default_fields_study_min)
      @default_fields_study_min = @fields_study_min
      # @xpath_study_length_min: The minimum number of characters in an xpath before studying is invoked when @fields_study_min == 1.
      @xpath_study_length_min = 100
      # A list of error messages:
      @errors = []
    end

    attr_reader :url, :browser, :stop_on_failure, :found_failure
    attr_writer :stop_on_failure, :found_failure


    # Start the session and open a browser to the URL defined at the start of
    # the test. If a browser session is already open, just return true.
    #
    # @example
    #   | Open browser |
    #
    # @raise [StopTestCannotConnect] if Selenium connection cannot be made
    #
    def open_browser
      return true if @browser.session_started?
      begin
        @browser.start :driver => @driver
      rescue
        raise StopTestCannotConnect,
          "Cannot connect to Selenium server at #{@browser.host}:#{@browser.port}"
      else
        visit @url
      end

      # Use javascript-xpath for IE, since it's a lot faster than the default
      if @browser.browser_string == '*iexplore'
        @browser.use_xpath_library('javascript-xpath')
      end

      # Make Selenium highlight elements whenever it locates them
      @browser.highlight_located_element = true
    end


    # Stop the session and close the browser window.
    # Show error messages in an exception if requested.
    #
    # @example
    #   | Close browser |
    #   | Close browser | and show errors |
    #   | Close browser | without showing errors |
    #
    def close_browser(show_errors='')
      @browser.close_current_browser_session
      end_study
      if in_conditional?
        # Note the lack of return.  This just adds an error to the stack if we're in a conditional.
        failure "If without matching End if"
        reset_conditionals
      end

      # Show errors in an exception if requested.
      if (!(/not|without/i === show_errors) && @errors.length > 0)
        raise StopTestStepFailed, @errors.join("\n").gsub('<','&lt;')
      end
      return true
    end

    # Show any current error messages.
    # Also clears the error message log.
    #
    # @example
    #   | Show | errors |
    #
    # @since 0.1.1
    #
    def errors
      current_errors = @errors
      @errors = []
      return current_errors.join("\n")
    end


    # Study the current web page, for more efficient parsing and data retrieval
    # on the Rsel side rather than the Selenium browser side.  Named for the
    # Perl "study" command.  Like its namesake, begin_study takes some time.
    #
    # Warning: When you study, you can learn information more quickly, but you
    # may not be aware of what's going on around you!  If any action you perform
    # has side-effects on the web page, you may not notice them while studying
    # is on.  This is why so many methods call {#end_study} automatically.  But
    # many cases remain where you could get into trouble if you forget this.
    #
    # Note: Calling this twice in a row without an intervening end_study will
    # result in the first end_study not actually ending studying.  Again, many
    # methods call end_study, so this is a possible, but unlikely, problem.
    def begin_study
      return skip_status if skip_step?
      fail_on_exception do
        @study.begin_section { page_to_study }
      end
    end

    # Turn off studying.  Several other methods call this, including:
    #   * {#click_back}
    #   * {#close_browser}
    #   * {#end_scenario}
    #   * {#page_loads_in_seconds_or_less}
    #   * {#refresh_page}
    #   * {#see_within_seconds}
    #   * {#do_not_see_within_seconds}
    #   * {#visit}
    # Don't be afraid to call this method as many times as you need to!
    def end_study
      @study.end_section
      return skip_status if skip_step?
      return true
    end

    # If studying is turned off, a flag is set, but the page is not deleted.
    # This method turns the flag back on, without reloading the web page.
    # Useful if you called one of the methods that calls {#end_study}, but
    # you expect that the page (or the relevant part of a page) didn't
    # actually change.  (Or you just want to verify data on the old page.)
    def continue_study
      return skip_status if skip_step?
      pass_if @study.keep_clean(true), "Unable to continue studying: no page has been studied!"
    end

    # Set the minimum number of fields that must appear in a set_fields
    # before studying is invoked.  "Never", or 0, turns off studying.
    # "Always", or 1, turns studying on whenever a long xpath is found.
    # Any other non-integer string resumes the studying pattern set in
    # the initial option.
    #
    # @param [String or Integer] level
    #   A (parsable) integer
    def set_fields_study_min(level=nil)
      return skip_status if skip_step?
      fail_on_exception do
        @fields_study_min = parse_fields_study_min(level, @default_fields_study_min)
        end_study if @fields_study_min == 0
      end
    end

    # Begin a new scenario, and forget about any previous failures.
    # This allows you to modularize your tests into standalone sections
    # that can run independently of previous scenarios, regardless of
    # whether those scenarios passed or failed.
    #
    # @example
    #   | Begin scenario |
    #
    # @since 0.0.9
    #
    def begin_scenario
      @found_failure = false
      @errors = []
      return true
    end


    # End the current scenario. For now, this does not do anything, but is
    # merely provided for symmetry with {#begin_scenario}.
    #
    # @example
    #   | End scenario |
    #
    # @since 0.0.9
    #
    def end_scenario
      end_study
      return true
    end


    # Load an absolute URL or a relative path in the browser.
    #
    # @param [String] path_or_url
    #   Relative path or absolute URL to load. Absolute URLs must be in the
    #   same domain as the URL that was passed to {#initialize}.
    #
    # @example
    #   | Visit | http://www.automation-excellence.com |
    #   | Visit | /software |
    #
    def visit(path_or_url)
      return skip_status if skip_step?
      end_study
      fail_on_exception do
        @browser.open(strip_tags(path_or_url))
      end
    end


    # Click the Back button to navigate to the previous page.
    #
    # @example
    #   | Click back |
    #
    def click_back
      return skip_status if skip_step?
      end_study
      fail_on_exception do
        @browser.go_back
      end
    end


    # Reload the current page.
    #
    # @example
    #   | Refresh page |
    #
    def refresh_page
      return skip_status if skip_step?
      end_study
      fail_on_exception do
        @browser.refresh
      end
    end


    # Maximize the browser window. May not work in some browsers.
    #
    # @example
    #   | Maximize browser |
    #
    def maximize_browser
      @browser.window_maximize
      return true
    end


    # Ensure that the given text appears on the current page.
    #
    # @param [String] text
    #   Plain text that should be visible on the current page
    #
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | See | Welcome, Marcus |
    #
    def see(text, scope=nil)
      return skip_status if skip_step?
      if scope == nil
        # Can't do a Study workaround - it doesn't know what's visible.
        return pass_if @browser.text?(text)
      else
        selector = loc("css=", '', scope).strip
        @study.undo_last_dirty # This method does not modify the browser page contents.
        # Default selenium_compare does not allow text around a glob.  Allow such text.
        searchtext = text
        searchtext = text.sub(/^(glob:)?\*?/, '*').sub(/\*?$/, '*') unless /^(exact|regexpi?):/ === text
        # Can't do a Study workaround - it doesn't know what's visible.
        fail_on_exception do
          return pass_if selenium_compare(@browser.get_text(selector), searchtext), "'#{text}' not found in '#{@browser.get_text(selector)}'"
        end
      end
    end


    # Ensure that the given text does not appear on the current page.
    #
    # @param [String] text
    #   Plain text that should not be visible on the current page
    #
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Do not see | Take a hike |
    #
    def do_not_see(text, scope=nil)
      return skip_status if skip_step?
      if scope == nil
        # Can't do a Study workaround - it doesn't know what's visible.
        return pass_if !@browser.text?(text)
      else
        selector = loc("css=", '', scope).strip
        @study.undo_last_dirty # This method does not modify the browser page contents.
        begin
          # Default selenium_compare does not allow text around a glob.  Allow such text.
          searchtext = text
          searchtext = text.sub(/^(glob:)?\*?/, '*').sub(/\*?$/, '*') unless /^(exact|regexpi?):/ === text
          # Can't do a Study workaround - it doesn't know what's visible.
          return pass_if !selenium_compare(@browser.get_text(selector), searchtext), "'#{text}' found in '#{@browser.get_text(selector)}'"
        rescue
          # Do not see the selector, so do not see the text within it.
          return true
        end
      end
    end


    # Temporally ensure text is present or absent

    # Ensure that the given text appears on the current page, eventually.
    #
    # @param [String] text
    #   Plain text that should be appear on or visible on the current page
    # @param [String] seconds
    #   Integer number of seconds to wait.
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    #
    # @example
    #   | Click | ajax_login | button |
    #   | See | Welcome back, Marcus | within | 10 | seconds |
    #   | Note | The following uses the Selenium default timeout: |
    #   | See | How do you feel? | within seconds | !{within:terminal} |
    #
    # @since 0.1.1
    #
    def see_within_seconds(text, seconds=-1, scope=nil)
      return skip_status if skip_step?
      end_study
      if scope == nil && (seconds.is_a? Hash)
        scope = seconds
        seconds = -1
      end
      seconds = @browser.default_timeout_in_seconds if seconds == -1
      if scope == nil
        return pass_if !(Integer(seconds)+1).times{ break if (@browser.text?(text) rescue false); sleep 1 }
        # This would be better if it worked:
        # pass_if @browser.wait_for(:text => text, :timeout_in_seconds => seconds);
      else
        selector = loc("css=", '', scope).strip
        # Default selenium_compare does not allow text around a glob.  Allow such text.
        text = text.sub(/^(glob:)?\*?/, '*').sub(/\*?$/, '*') unless /^(exact|regexpi?):/ === text
        return pass_if !(Integer(seconds)+1).times{ break if (selenium_compare(@browser.get_text(selector), text) rescue false); sleep 1 }
      end
    end

    # Ensure that the given text does not appear on the current page, eventually.
    #
    # @param [String] text
    #   Plain text that should disappear from or not be present on the current page
    # @param [String] seconds
    #   Integer number of seconds to wait.
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Click | close | button | !{within:popup_ad} |
    #   | Do not see | advertisement | within | 10 | seconds |
    #
    # @since 0.1.1
    #
    def do_not_see_within_seconds(text, seconds=-1, scope=nil)
      return skip_status if skip_step?
      end_study
      if scope == nil && (seconds.is_a? Hash)
        scope = seconds
        seconds = -1
      end
      seconds = @browser.default_timeout_in_seconds if seconds == -1
      if scope == nil
        pass_if !(Integer(seconds)+1).times{ break if (!@browser.text?(text) rescue false); sleep 1 }
        # This would be better if it worked:
        # pass_if @browser.wait_for(:no_text => text, :timeout_in_seconds => seconds);
      else
        selector = loc("css=", '', scope).strip
        # Default selenium_compare does not allow text around a glob.  Allow such text.
        text = text.sub(/^(glob:)?\*?/, '*').sub(/\*?$/, '*') unless /^(exact|regexpi?):/ === text
        # Re: rescue: If the scope is not found, the text is not seen.
        return pass_if !(Integer(seconds)+1).times{ break if (!selenium_compare(@browser.get_text(selector), text) rescue true); sleep 1 }
      end
    end



    # Ensure that the current page has the given title text.
    #
    # @param [String] title
    #   Text of the page title that you expect to see
    #
    # @example
    #   | See title | Our Homepage |
    #
    def see_title(title)
      return skip_status if skip_step?
      # Study workaround when possible.  (Probably won't happen a lot, but possible.)
      bodynode = @study.get_node('xpath=/html/head/title')
      return true if bodynode && bodynode.inner_text.strip == title
      pass_if @browser.get_title == title, "Page title is '#{@browser.get_title}', not '#{title}'"
    end


    # Ensure that the current page does not have the given title text.
    #
    # @param [String] title
    #   Text of the page title that you should not see
    #
    # @example
    #   | Do not see title | Someone else's homepage |
    #
    def do_not_see_title(title)
      return skip_status if skip_step?
      pass_if !(@browser.get_title == title)
    end

    # Ensure that an alert appears, optionally having the given text, within the
    # given time or the default timeout.
    #
    # @param [String] text
    #   Text of the alert that you expect to see
    #
    # @param [String] seconds
    #   Integer number of seconds to wait.
    #
    # @example
    #   | see alert within seconds |
    #     Validates any alert within the default timeout.
    #
    # @example
    #   | see alert | Illegal operation! Authorities have been notified. | within | 15 | seconds |
    #     Validates that the next alert that appears within the given timeout is as specified.
    #
    def see_alert_within_seconds(text=nil, seconds=-1)
      return skip_status if skip_step?
      # Handle the case of being given seconds, but not text.
      if seconds == -1
        begin
          if Integer(text.to_s).to_s == text.to_s
            seconds = text.to_s
            text = nil
          end
        rescue
        end
      end
      seconds = @browser.default_timeout_in_seconds if seconds == -1
      alert_text = nil
      if !(Integer(seconds)+1).times{ break if ((alert_text=@browser.get_alert) rescue false); sleep 1 }
        return true if text == nil
        return pass_if selenium_compare(alert_text, text), "Expected alert '#{text}', but got '#{alert_text}'!"
      else
        return failure
      end
    end

    # Ensure that a link exists on the page.
    #
    # @param [String] locator
    #   Text or id of the link, or image alt text
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Link | Logout | exists |
    #   | Link | Logout | exists | !{within:header} |
    #
    # @since 0.0.2
    #
    def link_exists(locator, scope={})
      return skip_status if skip_step?
      locator = loc(locator, 'link', scope)
      @study.undo_last_dirty # This method does not modify the browser page contents.

      # Study workaround when possible.
      bodynode = @study.get_node(locator)
      return true if bodynode
      pass_if @browser.element?(locator)
    end


    # Ensure that a button exists on the page.
    #
    # @param [String] locator
    #   Text, value, or id of the button
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Button | Search | exists |
    #   | Button | Search | exists | !{within:members} |
    #
    # @since 0.0.2
    #
    def button_exists(locator, scope={})
      return skip_status if skip_step?
      locator = loc(locator, 'button', scope)
      @study.undo_last_dirty # This method does not modify the browser page contents.

      # Study workaround when possible.
      bodynode = @study.get_node(locator)
      return true if bodynode
      pass_if @browser.element?(locator)
    end


    # Ensure that a table row with the given cell values exists.
    # Order does not matter as of v0.1.1.
    #
    # @param [String] cells
    #   Comma-separated cell values you expect to see.  If you need to include a
    #   literal comma, use the {#escape_for_hash} syntax, \'.
    #
    # @example
    #   | Row exists | First, Middle, Last, Email |
    #   | Row | First, Last, Middle, Email | exists |
    #
    # @since 0.0.3
    #
    def row_exists(cells)
      return skip_status if skip_step?
      locator = ("xpath=#{xpath_row_containing(cells.split(/, */).map{|s| escape_for_hash(s)})}")

      # Study workaround when possible.
      bodynode = @study.get_node(locator)
      return true if bodynode
      pass_if @browser.element?(locator)
    end

    #

    # Type a value into the given field. Passes if the field exists and is
    # editable. Fails if the field is not found, or is not editable.
    #
    # @param [String] text
    #   What to type into the field
    # @param [String] locator
    #   Label, name, or id of the field you want to type into
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Type | Dale | into | First name | field |
    #   | Type | Dale | into | First name | field | !{within:contact} |
    #
    def type_into_field(text, locator, scope={})
      return skip_status if skip_step?
      field = loc(locator, 'field', scope)
      fail_on_exception do
        ensure_editable(field) && @browser.type(field, text)
      end
    end


    # Fill in a field with the given text. Passes if the field exists and is
    # editable. Fails if the field is not found, or is not editable.
    #
    # @param [String] locator
    #   Label, name, or id of the field you want to type into
    # @param [String] text
    #   What to type into the field
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Fill in | First name | with | Eric |
    #
    def fill_in_with(locator, text, scope={})
      return skip_status if skip_step?
      type_into_field(text, locator, scope)
    end

    # Verify that a text field contains the given text. The field may include
    # additional text, as long as the expected value is in there somewhere.
    #
    # @param [String] locator
    #   Label, name, or id of the field you want to inspect
    # @param [String] text
    #   Text to expect in the field
    #
    # @example
    #   | Field | First name | contains | Eric |
    #
    def field_contains(locator, text, scope={})
      return skip_status if skip_step?
      begin
        field = @browser.field(loc(locator, 'field', scope))
        @study.undo_last_dirty # This method does not modify the browser page contents.
      rescue
        failure "Can't identify field #{locator}"
      else
        pass_if field.include?(text), "Field contains '#{field}', not '#{text}'"
      end
    end


    # Verify that a text field's value equals the given text. The value must
    # match exactly.
    #
    # @param [String] locator
    #   Label, name, or id of the field you want to inspect
    # @param [String] text
    #   Text to expect in the field
    #
    # @example
    #   | Field | First name | equals | Eric |
    #   | Field | First name | equals; | Eric | !{within:contact} |
    #
    def field_equals(locator, text, scope={})
      return skip_status if skip_step?
      begin
        field = @browser.field(loc(locator, 'field', scope))
        @study.undo_last_dirty # This method does not modify the browser page contents.
      rescue
        failure "Can't identify field #{locator}"
      else
        pass_if field == text, "Field contains '#{field}', not '#{text}'"
      end
    end


    # Click on a link or button, and wait for a page to load.
    #
    # @param [String] locator
    #   Text, value or id of the link or button to click
    #
    # @example
    #   | Click | Next   |
    #   | Click | Logout |
    #   | Click; | Logout | !{within:header} |
    #
    def click(locator, scope={})
      return skip_status if skip_step?
      fail_on_exception do
        @browser.click(loc(locator, 'link_or_button', scope))
      end
    end

    # Click on a link.
    #
    # @param [String] locator
    #   Text or id of the link, or image alt text
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Click | Logout | link |
    #   | Follow | Logout |
    #   | Click | Logout | link | !{within:header} |
    #   | Click | Edit | link | !{in_row:Eric} |
    #
    def click_link(locator, scope={})
      return skip_status if skip_step?
      fail_on_exception do
        @browser.click(loc(locator, 'link', scope))
      end
    end
    alias_method :follow, :click_link


    # Press a button. Passes if the button exists and is not disabled.
    # Fails if the button is not found, or is disabled.
    #
    # @param [String] locator
    #   Text, value, or id of the button
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Click | Search | button |
    #   | Press | Login |
    #   | Click | Search | button | !{within:customers} |
    #
    def click_button(locator, scope={})
      return skip_status if skip_step?
      button = loc(locator, 'button', scope)
      fail_on_exception do
        ensure_editable(button) && @browser.click(button)
      end
    end
    alias_method :press, :click_button


    # Enable (check) a checkbox by clicking on it. If the checkbox is already
    # enabled, do nothing. Passes if the checkbox exists and is editable. Fails
    # if the checkbox is not found, or is not editable.
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to check
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Enable | Send me spam | checkbox |
    #   | Enable | Send me spam | checkbox | !{within:opt_in} |
    #
    def enable_checkbox(locator, scope={})
      return skip_status if skip_step?
      cb = loc(locator, 'checkbox', scope)
      fail_on_exception do
        ensure_editable(cb) && checkbox_is_disabled(cb) && @browser.click(cb)
      end
    end


    # Disable (uncheck) a checkbox by clicking on it. If the checkbox is
    # already disabled, do nothing. Passes if the checkbox exists and is
    # editable. Fails if the checkbox is not found, or is not editable.
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to uncheck
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Disable | Send me spam | checkbox |
    #   | Disable | Send me spam | checkbox | !{within:opt_in} |
    #
    def disable_checkbox(locator, scope={})
      return skip_status if skip_step?
      cb = loc(locator, 'checkbox', scope)
      fail_on_exception do
        ensure_editable(cb) && checkbox_is_enabled(cb) && @browser.click(cb)
      end
    end


    # Verify that a given checkbox is enabled (checked)
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to inspect
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Checkbox | send me spam | is enabled |
    #   | Checkbox | send me spam | is enabled | !{within:opt_in} |
    #
    def checkbox_is_enabled(locator, scope={})
      return skip_status if skip_step?
      xp = loc(locator, 'checkbox', scope)
      @study.undo_last_dirty # This method does not modify the browser page contents.
      begin
        enabled = @browser.checked?(xp)
      rescue
        failure "Can't identify checkbox #{locator}"
      else
        return enabled
      end
    end


    # Verify that a given radio button is enabled (checked)
    #
    # @param [String] locator
    #   Label, value, or id of the radio button to inspect
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Radio | medium | is enabled |
    #   | Radio | medium | is enabled | !{within:shirt_size} |
    #
    # @since 0.0.4
    #
    def radio_is_enabled(locator, scope={})
      return skip_status if skip_step?
      xp = loc(locator, 'radio_button', scope)
      @study.undo_last_dirty # This method does not modify the browser page contents.
      begin
        enabled = @browser.checked?(xp)
      rescue
        failure "Can't identify radio #{locator}"
      else
        return enabled
      end
    end


    # Verify that a given checkbox is disabled (unchecked)
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to inspect
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Checkbox | send me spam | is disabled |
    #   | Checkbox | send me spam | is disabled | !{within:opt_in} |
    #
    def checkbox_is_disabled(locator, scope={})
      return skip_status if skip_step?
      xp = loc(locator, 'checkbox', scope)
      @study.undo_last_dirty # This method does not modify the browser page contents.
      begin
        enabled = @browser.checked?(xp)
      rescue
        failure "Can't identify checkbox #{locator}"
      else
        return !enabled
      end
    end


    # Verify that a given radio button is disabled (unchecked)
    #
    # @param [String] locator
    #   Label, value, or id of the radio button to inspect
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Radio | medium | is disabled |
    #   | Radio | medium | is disabled | !{within:shirt_size} |
    #
    # @since 0.0.4
    #
    def radio_is_disabled(locator, scope={})
      return skip_status if skip_step?
      xp = loc(locator, 'radio_button', scope)
      @study.undo_last_dirty # This method does not modify the browser page contents.
      begin
        enabled = @browser.checked?(xp)
      rescue
        failure "Can't identify radio #{locator}"
      else
        return !enabled
      end
    end


    # Select a radio button. Passes if the radio button exists and is editable.
    # Fails if the radiobutton is not found, or is not editable.
    #
    # @param [String] locator
    #   Label, id, or name of the radio button to select
    # @param [Hash] scope
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Select | female | radio |
    #   | Select | female | radio | !{within:gender} |
    #
    def select_radio(locator, scope={})
      return skip_status if skip_step?
      radio = loc(locator, 'radio_button', scope)
      fail_on_exception do
        ensure_editable(radio) && @browser.click(radio)
      end
    end


    # Select an option from a dropdown/combo box. Passes if the dropdown exists,
    # is editable, and includes the given option. Fails if the dropdown is not
    # found, the option is not found, or the dropdown is not editable.
    #
    # @param [String] option
    #   The option to choose from the dropdown
    # @param [String] locator
    #   Label, name, or id of the dropdown
    #
    # @example
    #   | Select | Tall | from | Height | dropdown |
    #   | Select | Tall | from dropdown | Height |
    #
    def select_from_dropdown(option, locator, scope={})
      return skip_status if skip_step?
      dropdown = loc(locator, 'select', scope)
      fail_on_exception do
        ensure_editable(dropdown) && @browser.select(dropdown, option)
      end
    end


    # Check whether an option exists in a dropdown/combo box.
    #
    # @param [String] locator
    #   Label, name, or id of the dropdown
    # @param [String] option
    #   The option to look for
    #
    # @example
    #   | Dropdown | Height | includes | Tall |
    #
    # @since 0.0.2
    #
    def dropdown_includes(locator, option, scope={})
      return skip_status if skip_step?
      # TODO: Apply scope
      dropdown = XPath::HTML.select(locator)
      opt = dropdown[XPath::HTML.option(option)]
      opt_str = "xpath=#{opt.to_s}"
      # Study workaround when possible.
      bodynode = @study.get_node(opt_str)
      return true if bodynode
      pass_if @browser.element?(opt_str)
    end


    # Check whether an option is currently selected in a dropdown/combo box.
    #
    # @param [String] locator
    #   Label, name, or id of the dropdown
    # @param [String] option
    #   The option you expect to be selected
    #
    # @example
    #   | Dropdown | Height | equals | Tall |
    #
    # @since 0.0.2
    #
    def dropdown_equals(locator, option, scope={})
      return skip_status if skip_step?
      begin
        selected = @browser.get_selected_label(loc(locator, 'select', scope))
        @study.undo_last_dirty # This method does not modify the browser page contents.
      rescue
        failure "Can't identify dropdown #{locator}"
      else
        pass_if selected == option, "Dropdown equals '#{selected}', not '#{option}'"
      end
    end


    # Pause for a certain number of seconds.
    #
    # @param [String, Int] seconds
    #   How many seconds to pause
    #
    # @example
    #   | Pause | 5 | seconds |
    #
    def pause_seconds(seconds)
      return skip_status if skip_step?
      sleep seconds.to_i
      return true
    end
    alias_method :pause_secs, :pause_seconds


    # Wait some number of seconds for the current page request to finish.
    # Fails if the page does not finish loading within the specified time.
    #
    # @param [String, Int] seconds
    #   How long to wait for before timing out
    #
    # @example
    #   | Page loads in | 10 | seconds or less |
    #
    def page_loads_in_seconds_or_less(seconds)
      return skip_status if skip_step?
      end_study
      fail_on_exception do
        @browser.wait_for_page_to_load(seconds)
      end
    end


    # A generic way to fill in any field, of any type. (Just about.)
    # Kind of nasty since it needs to use Javascript on the page.
    #
    # Types accepted:
    #
    # * a*
    # * button*
    # * input
    #   * type=button*
    #   * type=checkbox
    #   * type=image*
    #   * type=radio*
    #   * type=reset*
    #   * type=submit*
    #   * type=text
    # * select
    # * textarea
    #
    # \* Value is ignored: this control type is just clicked/selected.
    #
    # @param [String] locator
    #   Label, name, or id of the field control. Identification by
    #   non-Selenium methods may not work for some links and buttons.
    # @param [String] value
    #   Value you want to set the field to. (Default: empty string.)
    #   Parsed by {#string_is_true?}
    #
    # @since 0.1.1
    #
    def set_field(locator, value='', scope={})
      return skip_status if skip_step?
      fail_on_exception do
        loceval = loc(locator, 'field', scope)
        mytagname = ''
        begin
          mytagname = tagname(loceval)
        rescue
          loceval = loc(locator, 'link_or_button', scope)
          mytagname = tagname(loceval)
        end
        #puts "My tag name is #{mytagname}\n"
        #puts "My loceval is #{loceval}\n" #if /^id=/ === loceval
        case mytagname
        when 'input.text', /^textarea\./
          return type_into_field(value, loceval)
        when 'input.radio'
          return select_radio(loceval)
        when 'input.checkbox'
          if string_is_true?(value)
            return enable_checkbox(loceval)
          else
            return disable_checkbox(loceval)
          end
        when /^select\./
          return select_from_dropdown(value, loceval)
        when /^(a|button)\./,'input.button','input.submit','input.image','input.reset'
          return click(loceval)
        else
          return failure("Unidentified field #{locator}.")
        end
      end
    end


    # Set a value (with {#set_field}) in the named field, based on the given
    # name/value pairs. Uses {#escape_for_hash} to allow certain characters in
    # FitNesse.
    #
    # @param [String] field
    #   A Locator or a name listed in the ids hash below. If a name listed in
    #   the ids below, this field is case-insensitive.
    # @param [String] value
    #   Plain text to go into a field
    # @param ids
    #   A hash mapping common names to Locators. (Optional, but redundant
    #   without it) The hash keys are case-insensitive.
    #
    # @since 0.1.1
    #
    def set_field_among(field, value, ids={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field. Fix it.
      ids = {} if ids == ""

      normalize_ids(ids)

      if ids[field.downcase]
        return set_field(escape_for_hash(ids[field.downcase]), value, scope)
      else
        return set_field(field, value, scope)
      end
    end

    # Set values (with {#set_field}) in the named fields of a hash, based on the
    # given name/value pairs. Uses {#escape_for_hash} to allow certain
    # characters in FitNesse. Note: Order of entries is not guaranteed, and
    # depends on the version of Ruby on your server!
    #
    # @param fields
    #   A key-value hash where the keys are Locators (case-sensitive) and the
    #   values are the string values you want in the fields.
    #
    # @since 0.1.1
    #
    def set_fields(fields={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field. Fix it.
      fields = {} if fields == ""

      method_study = false
      if @fields_study_min != 0 && @fields_study_min <= fields.length
        method_study = true
        # Then we want the page to be studied throughout this method.
        begin_study
      end

      fields.each do |key, value|
        key_esc = escape_for_hash(key.to_s)
        value_esc = escape_for_hash(value.to_s)
        unless set_field(key_esc, value_esc, scope)
          end_study if method_study
          return failure "Failed to set field #{key_esc} to #{value_esc}"
        end
      end
      end_study if method_study
      return true
    end

    # Set values (with {#set_field}) in the named fields, based on the given
    # name/value pairs, and with mapping of names in the ids field. Uses
    # {#escape_for_hash} to allow certain characters in FitNesse. Note: Order
    # of entries is not guaranteed, and depends on the version of Ruby on your
    # server!
    #
    # @param fields
    #   A key-value hash where the keys are keys of the ids hash
    #   (case-insensitive), or Locators (case-sensitive), and the values are
    #   the string values you want in the fields.
    # @param ids
    #   A hash mapping common names to Locators. (Optional, but redundant
    #   without it)  The hash keys are case-insensitive.
    #
    # @example
    #   Suppose you have a nasty form whose fields have nasty locators. Suppose
    #   further that you want to fill in this form, many times, filling in
    #   different fields different ways. Begin by creating a Scenario table:
    #
    #       | scenario | Set nasty form fields | values |
    #       | Set | @values | fields among | !{Name:id=nasty_field_name_1,Email:id=nasty_field_name_2,E-mail:id=nasty_field_name_2,Send me spam:id=nasty_checkbox_name_1} |
    #
    #   Using that you can now say something like:
    #
    #       | Set nasty form fields | !{Name:Ken,email:ken@kensaddress.com,send me spam: no} |
    #
    #   Or:
    #
    #       | Set nasty form fields | !{Name:Ken,Send me Spam: no} |
    #
    #   Or:
    #
    #       | Set nasty form fields | !{name:Ken,e-mail:,SEND ME SPAM: yes} |
    #
    # @since 0.1.1
    #
    def set_fields_among(fields={}, ids={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field. Fix it.
      ids = {} if ids == ""
      fields = {} if fields == ""

      method_study = false
      if @fields_study_min != 0 && @fields_study_min <= fields.length
        method_study = true
        # Then we want the page to be studied throughout this method.
        begin_study
      end

      fields.each do |key, value|
        key_esc = escape_for_hash(key.to_s)
        value_esc = escape_for_hash(value.to_s)
        unless set_field_among(key_esc, value_esc, ids, scope)
          end_study if method_study
          return failure("Failed to set #{key_esc} (#{ids[key_esc]}) to #{value_esc}")
        end
      end
      end_study if method_study
      return true
    end

    # A generic way to check any field, of any type. (Just about.) Kind of
    # nasty since it needs to use Javascript on the page.
    #
    # Types accepted:
    #
    # * a*
    # * button*
    # * input
    #   * type=button*
    #   * type=checkbox
    #   * type=image*
    #   * type=radio*
    #   * type=reset*
    #   * type=submit*
    #   * type=text
    # * select
    # * textarea
    #
    # \* Value is ignored: this control type is just clicked/selected.
    #
    # @param [String] locator
    #   Label, name, or id of the field control. Identification by
    #   non-Selenium methods may not work for some links and buttons.
    # @param [String] value
    #   Value you want to verify the field equal to. (Default: empty string.)
    #   Parsed by {#string_is_true?}
    #
    # @since 0.1.1
    #
    def generic_field_equals(locator, value='', scope={})
      return skip_status if skip_step?
      fail_on_exception do
        loceval = loc(locator, 'field', scope)
        @study.undo_last_dirty # This method does not modify the browser page contents.
        case tagname(loceval)
        when 'input.text', /^textarea\./
          return field_equals(loceval, value)
        when 'input.radio'
          if string_is_true?(value)
            return radio_is_enabled(loceval)
          else
            return radio_is_disabled(loceval)
          end
        when 'input.checkbox'
          if string_is_true?(value)
            return checkbox_is_enabled(loceval)
          else
            return checkbox_is_disabled(loceval)
          end
        when /^select\./
          return dropdown_equals(loceval, value)
        else
          return failure("Unidentified field for comparison: #{locator}.")
        end
      end
    end

    # Check a value (with {#set_field}) in the named field, based on the given
    # name/value pairs. Uses {#escape_for_hash} to allow certain characters in
    # FitNesse.
    #
    # @param [String] field
    #   A Locator or a name listed in the ids hash below. If a name listed in
    #   the ids below, this field is case-insensitive.
    # @param [String] value
    #   Plain text to go into a field
    # @param ids
    #   A hash mapping common names to Locators. (Optional, but redundant
    #   without it) The hash keys are case-insensitive.
    #
    # @since 0.1.1
    #
    def field_equals_among(field, value, ids={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field. Fix it.
      ids = {} if ids == ""

      normalize_ids(ids)

      if ids[field.downcase]
        return generic_field_equals(escape_for_hash(ids[field.downcase]), value, scope)
      else
        return generic_field_equals(field, value, scope)
      end
    end

    # Check values (with {#set_field}) in the named fields of a hash, based on
    # the given name/value pairs. Uses {#escape_for_hash} to allow certain
    # characters in FitNesse. Note: Order of entries is not guaranteed, and
    # depends on the version of Ruby on your server!
    #
    # @param fields
    #   A key-value hash where the keys are Locators (case-sensitive) and the
    #   values are the string values you want in the fields.
    #
    # @since 0.1.1
    #
    def fields_equal(fields={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field. Fix it.
      fields = {} if fields == ""

      method_study = false
      if @fields_study_min != 0 && @fields_study_min <= fields.length
        method_study = true
        # Then we want the page to be studied throughout this method.
        begin_study
      end

      fields.keys.each do |field|
        unless generic_field_equals(escape_for_hash(field.to_s), escape_for_hash(fields[field]), scope)
          end_study if method_study
          return failure 
        end
      end
      if method_study
        end_study 
        @study.undo_last_dirty
      end
      return true
    end

    # Check values (with {#set_field}) in the named fields, based on the given
    # name/value pairs, and with mapping of names in the ids field. Uses
    # {#escape_for_hash} to allow certain characters in FitNesse. Note: Order
    # of entries is not guaranteed, and depends on the version of Ruby on your
    # server!
    #
    # @param fields
    #   A key-value hash where the keys are keys of the ids hash
    #   (case-insensitive), or Locators (case-sensitive),
    #   and the values are the string values you want in the fields.
    # @param ids
    #   A hash mapping common names to Locators. (Optional, but redundant
    #   without it)  The hash keys are case-insensitive.
    #
    # @example
    #   Suppose you have a nasty form whose fields have nasty locators.
    #   Suppose further that you want to fill in this form, many times, filling
    #   in different fields different ways.
    #   Begin by creating a Scenario table:
    #
    #       | scenario | Check nasty form fields | values |
    #       | fields equal | @values | among | !{Name:id=nasty_field_name_1,Email:id=nasty_field_name_2,E-mail:id=nasty_field_name_2,Send me spam:id=nasty_checkbox_name_1} |
    #
    #   Using that you can now say something like:
    #
    #       | Check nasty form fields | !{Name:Ken,email:ken@kensaddress.com,send me spam: no} |
    #
    #   Or:
    #
    #       | Check nasty form fields | !{Name:Ken,Send me Spam: no} |
    #
    #   Or:
    #
    #       | Check nasty form fields | !{name:Ken,e-mail:,SEND ME SPAM: yes} |
    #
    # @since 0.1.1
    #
    def fields_equal_among(fields={}, ids={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field. Fix it.
      ids = {} if ids == ""
      fields = {} if fields == ""

      method_study = false
      if @fields_study_min != 0 && @fields_study_min <= fields.length
        method_study = true
        # Then we want the page to be studied throughout this method.
        begin_study
      end

      fields.keys.each do |field|
        unless field_equals_among(escape_for_hash(field.to_s), escape_for_hash(fields[field]), ids, scope)
          end_study if method_study
          return failure 
        end
      end
      if method_study
        end_study 
        @study.undo_last_dirty
      end
      return true
    end

    # Invoke a missing method. If a method is called on a SeleniumTest
    # instance, and that method is not explicitly defined, this method
    # will check to see whether the underlying Selenium::Client::Driver
    # instance can respond to that method. If so, that method is called
    # instead.
    #
    # Prefixing a method with "check_" will verify the return string
    # against the last argument.  This allows checking string values
    # within an if block.
    #
    # @since 0.0.6
    #
    def method_missing(method, *args, &block)
      return skip_status if skip_step?
      do_check = false
      if(/^check_/ === method.to_s)
        # This emulates the FitNesse | Check | prefix, without the messy string return.
        do_check = true
        method = method.to_s.sub(/^check_/,'').to_sym
        check_against = args.pop.to_s
      end

      # Allow methods like "Type" that have Ruby homonyms to be called with a "selenium" prefix.
      method = method.to_s.sub(/^selenium_/,'').to_sym if /^selenium_/ === method.to_s

      if @browser.respond_to?(method)
        # Most methods should dirty the study object.  These include get_eval and get_expression.
        @study.dirty unless /^(get_(el|[^e])|is_)/ === method.to_s
        begin
          result = @browser.send(method, *args, &block)
        rescue
          failure "Method #{method} error"
        else
          # The method call succeeded
          # Should we check this against another string?
          if do_check
            return pass_if selenium_compare(result.to_s, check_against), "Expected '#{check_against}', but got '#{result.to_s}'"
          end
          # Did it return true or false?
          return failure if result == false
          # If a string, return that. We might Check or Show it.
          return result if result == true || (result.is_a? String)
          # Not a Boolean return value or string--assume passing
          return true
        end
      else
        super
      end
    end


    # Return true if SeleniumTest explicitly responds to a given method
    # name, or if the underlying Selenium::Client::Driver instance can
    # respond to it. This is a counterpart to {#method_missing}, used
    # for checking whether a given method can be called on this instance.
    #
    # @since 0.0.6
    #
    def respond_to?(orgmethod, include_private=false)
      # Allow methods like "Type" that have Ruby homonyms to be called with a "selenium" prefix.
      method = orgmethod.to_s.sub(/^(check_)?(selenium_)?/,'')
      if @browser.respond_to?(method)
        true
      else
        super
      end
    end

    # Conditionals

    # If I see the given text, do the steps until I see an otherwise or end_if.
    # Otherwise do not do those steps.
    #
    # @param [String] text
    #   Plain text that should be visible on the current page
    #
    # @example
    #   | If I see | pop-over ad |
    #   | Click | Close | button |
    #   | End if |
    #
    # @since 0.1.1
    #
    def if_i_see(text)
      return false if aborted?
      cond = false
      begin
        cond = @browser.text?(text)
      rescue
        # Something went wrong.  Therefore, I did not see the text.
      end
      return push_conditional(cond)
    end

    # If the given parameter is "yes" or "true", do the steps until I see an
    # otherwise or end_if. Otherwise do not do those steps.
    #
    # @param [String] text
    #   A string. Parsed by {#string_is_true?}. True values cause the
    #   following steps to run. Anything else does not.
    #
    # @example
    #   | If parameter | ${spam_me} |
    #   | Enable | Send me spam | checkbox |
    #   | See | Email: | within | 10 | seconds |
    #   | Type | ${spam_me_email} | into field | spammable_email |
    #   | End if |
    #
    # @since 0.1.1
    #
    def if_parameter(text)
      return false if aborted?
      return push_conditional(string_is_true?(text))
    end

    # If the first parameter is the same as the second, do the steps until I see an
    # otherwise or end_if. Otherwise do not do those steps.
    #
    # @param [String] text
    #   A string.
    #
    # @param [String] expected
    #   Another string.
    #   Uses `selenium_compare', so glob, regexp, etc. are accepted.
    #
    # @example
    #   | $name= | Get value | id=response_field |
    #   | If | $name | is | George |
    #   | Type | Hi, George. | into | chat | field |
    #   | Otherwise |
    #   | Type | Go away! Bring me George! | into | chat | field |
    #   | End if |
    #
    # @since 0.1.1
    #
    def if_is(text, expected)
      return false if aborted?
      return push_conditional(selenium_compare(text, expected))
    end

    # End an if block.
    #
    # @since 0.1.1
    #
    def end_if
      return false if aborted?
      # If there was no prior matching if, fail.
      return failure "End if without matching if" if !in_conditional?

      last_status = @conditional_stack.pop
      # If this end_if is within an un-executed if block, don't execute it.
      return nil if last_status == nil
      return true
    end

    # The else case to match any if.
    #
    # @example
    # | if parameter | ${login_by_phone} |
    # | type | ${login} | into field | phone_number |
    # | otherwise |
    # | type | ${login} | into field | login |
    # | end if |
    #
    # @since 0.1.1
    #
    def otherwise
      return false if aborted?
      # If there was no prior matching if, fail.
      return failure "Otherwise without matching if" if !in_conditional?

      # If this otherwise is within an un-executed if block, don't execute it.
      return nil if in_nil_conditional?

      last_stack = @conditional_stack.pop
      @conditional_stack.push !last_stack
      return true if @conditional_stack.last == true
      return nil if @conditional_stack.last == false
      return failure
    end

    # Reset the conditional stack to its initial state. This method is included
    # mainly for unit testing purposes, and is not intended to be called by
    # normal test scripts.
    #
    # @since 0.1.2
    #
    def reset_conditionals
      @conditional_stack = [true]
    end

    private

    # Return true if we're inside a conditional block, false otherwise.
    #
    # @since 0.1.2
    #
    def in_conditional?
      return @conditional_stack.length > 1
    end

    # Return true if we're inside a nil conditional block (one whose evaluation
    # doesn't matter because it was precluded by an outer conditional block
    # that was false).
    #
    # @since 0.1.2
    #
    def in_nil_conditional?
      return in_conditional? && @conditional_stack.last == nil
    end

    # Return true if we're inside a conditional block that was skipped,
    # either because it evaluated false, or because it was inside another
    # conditional that evaluated false.
    #
    # @since 0.1.2
    #
    def in_skipped_conditional?
      return in_conditional? && !@conditional_stack.last
    end

    # Push a conditional result onto the stack.
    #
    # @param [Boolean] result
    #   The result of the conditional expression you're pushing.
    #
    # @return [Boolean, nil]
    #   true if the result is true, false otherwise.
    #
    # @since 0.1.2
    #
    def push_conditional(result)
      # If this if is inside a block that's not running, record that.
      if in_skipped_conditional?
        @conditional_stack.push nil
        return nil
      end

      # Test the condition.
      @conditional_stack.push result

      return true if @conditional_stack.last == true
      return nil if @conditional_stack.last == false
      return failure
    end

    # Overrides the support.rb loc() method, allowing searching a studied page
    # to try simplify a CSS or XPath expression to an id= or name= expression.
    # 
    # @param [Boolean] try_study
    #   Try to use the studied page to simplify the path?  Defaults to true.
    def loc(locator, kind='', scope={}, try_study=true)
      locator = super(locator, kind, scope)
      return locator unless try_study
      @study.study(page_to_study) if(@fields_study_min == 1 && !@study.clean? && locator[0,6] == 'xpath=' && locator.length >= @xpath_study_length_min)
      begin
        retval = @study.simplify_locator(locator)
      rescue
        retval = locator
      end
      @study.dirty
      return retval
    end

    # Returns the HTML of the current browser page, for studying.
    # Just to keep this consistent.
    def page_to_study
      #puts "Page to study: <html>#{@browser.get_eval('window.document.getElementsByTagName(\'html\')[0].innerHTML')}</html>"
      return "<html>#{@browser.get_eval('window.document.getElementsByTagName(\'html\')[0].innerHTML')}</html>"
    end

    # Parse the argument given into a value for @fields_study_min
    # Returns the value, rather than setting @fields_study_min.
    def parse_fields_study_min(s, default)
      begin
        s = s.downcase.strip
      rescue
      end

      case s
      when 'never'
        return 0
      when 'always'
        return 1
      else
        begin
          return Integer(s.gsub(/[^0-9]/,''))
        rescue
          # Default case:
          return default
        end
      end
    end

    # Use Javascript to determine the type of field referenced by loceval.
    # Also turns loceval into an id= locator if possible.
    #
    # @param [String] loceval
    #   Selenium-style locator
    #   Warning: This parameter is effectively passed by reference!
    #   We attempt to replace an xpath locator with an id=.
    #
    # @since 0.1.1
    #
    def tagname(loceval)
      tname = nil
      if @study.clean?
        tname = @study.get_node(loceval)
        # If we've studied, loceval should have already been converted to an id, or name, etc. So trying to change it again would be pointless.
        return "#{tname.node_name}.#{tname['type']}" unless tname == nil
        # If get_studied_node failed, try the old-fashioned way.
        #puts "Studying tagname #{loceval} failed."
      end
      tname = @browser.get_eval(
        'var ev=this.browserbot.findElement("' +
        loceval + '");ev.tagName+"."+ev.type+";"+((ev.id != "" && window.document.getElementById(ev.id)==ev)?ev.id:"")').downcase

      tname = tname.split(';',2)
      # This modifies loceval in-place.
      loceval[0,loceval.length] = "id=#{tname[1]}" if tname[1] != ''
      return tname[0]
    end

    # Execute the given block, and return false if it raises an exception.
    # Otherwise, return true.
    #
    # @example
    #   fail_on_exception do
    #     # some code that might raise an exception
    #   end
    #
    def fail_on_exception
      begin
        yield
      rescue => e
        #puts e.message
        #puts e.backtrace
        failure("#{e.message}:<br>#{e.backtrace.join("\n")}")
      else
        return true
      end
    end


    # Raise an exception if the given input is not editable.
    #
    # @param [String] selenium_locator
    #   Locator string for an input (text field, checkbox, or button) as
    #   understood by Selenium
    #
    # @since 0.0.7
    #
    # @raise [StopTestInputDisabled] if the given input is not editable
    #
    def ensure_editable(selenium_locator)
      if @browser.is_editable(selenium_locator)
        return true
      else
        raise StopTestInputDisabled, "Input is not editable"
      end
    end


    # Indicate a failure by returning `false` and setting `@found_failure = true`.
    #
    # @since 0.0.6
    #
    def failure(reason='')
      @found_failure = true
      @errors.push(reason) unless (reason == '')
      return false
    end


    # Pass if the given condition is true; otherwise, fail with {#failure}.
    #
    # @since 0.0.6
    #
    def pass_if(condition, errormsg='')
      if condition
        return true
      else
        failure(errormsg)
      end
    end


    # Conditionals

    # Should the current step be skipped, either because the test was aborted or
    # because we're in a conditional?
    #
    # @since 0.1.1
    #
    def skip_step?
      return aborted? || in_skipped_conditional?
    end

    # Presuming the current step should be skipped, what status should I return?
    #
    # @since 0.1.1
    #
    def skip_status
      return false if aborted?
      return nil if in_skipped_conditional?
    end


    # Return true if this test has been aborted.
    #
    # @since 0.0.9
    #
    def aborted?
      return @found_failure && @stop_on_failure
    end

  end
end

