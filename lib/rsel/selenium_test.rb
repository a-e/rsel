#require File.join(File.dirname(__FILE__), 'exceptions')

require 'rubygems'
require 'xpath'
require 'selenium/client'
require 'rsel/support'
require 'rsel/exceptions'

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
      @url = url.gsub(/<\/?[^>]*>/, '')
      @browser = Selenium::Client::Driver.new(
        :host => options[:host] || 'localhost',
        :port => options[:port] || 4444,
        :browser => options[:browser] || '*firefox',
        :url => @url,
        :default_timeout_in_seconds => options[:timeout] || 300)
      # Accept Booleans or strings, case-insensitive
      if options[:stop_on_failure].to_s =~ /true/i
        @stop_on_failure = true
      else
        @stop_on_failure = false
      end
      @found_failure = false
      @conditional_stack = [ true ]
    end

    attr_reader :url, :browser, :stop_on_failure, :found_failure
    attr_writer :stop_on_failure, :found_failure


    # Start the session and open a browser to the URL defined at the start of
    # the test.
    #
    # @example
    #   | Open browser |
    #
    # @raise [StopTestCannotConnect] if Selenium connection cannot be made
    #
    def open_browser
      begin
        @browser.start_new_browser_session
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
    #
    # @example
    #   | Close browser |
    #
    def close_browser
      @browser.close_current_browser_session
      return true
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
      fail_on_exception do
        @browser.open(path_or_url)
      end
    end


    # Click the Back button to navigate to the previous page.
    #
    # @example
    #   | Click back |
    #
    def click_back
      return skip_status if skip_step?
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
    # @example
    #   | See | Welcome, Marcus |
    #
    def see(text)
      return skip_status if skip_step?
      pass_if @browser.text?(text)
    end


    # Ensure that the given text does not appear on the current page.
    #
    # @param [String] text
    #   Plain text that should not be visible on the current page
    #
    # @example
    #   | Do not see | Take a hike |
    #
    def do_not_see(text)
      return skip_status if skip_step?
      pass_if !@browser.text?(text)
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
    # @example
    #   | Click | ajax_login | button |
    #   | See | Welcome back, Marcus | within | 10 | seconds |
    #
    # @since 0.1.1
    #
    def see_within_seconds(text, seconds, scope={})
      return skip_status if skip_step?
      pass_if !(Integer(seconds)+1).times{ break if (@browser.text?(text) rescue false); sleep 1 }
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
    def do_not_see_within_seconds(text, seconds, scope={})
      return skip_status if skip_step?
      pass_if !(Integer(seconds)+1).times{ break if (!@browser.text?(text) rescue false); sleep 1 }
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
      pass_if @browser.get_title == title
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
      pass_if @browser.element?(loc(locator, 'link', scope))
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
      pass_if @browser.element?(loc(locator, 'button', scope))
    end


    # Ensure that a table row with the given cell values exists.
    #
    # @param [String] cells
    #   Comma-separated cell values you expect to see
    #
    # @example
    #   | Row exists | First, Middle, Last, Email |
    #   | Row | First, Middle, Last, Email | exists |
    #
    # @since 0.0.3
    #
    def row_exists(cells)
      return skip_status if skip_step?
      row = XPath.descendant(:tr)[XPath::HTML.table_row(cells.split(/, */))]
      pass_if @browser.element?("xpath=#{row.to_s}")
    end


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
      rescue
        failure
      else
        pass_if field.include?(text)
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
      rescue
        failure
      else
        pass_if field == text
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
      begin
        enabled = @browser.checked?(xp)
      rescue
        failure
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
      begin
        enabled = @browser.checked?(xp)
      rescue
        failure
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
      begin
        enabled = @browser.checked?(xp)
      rescue
        failure
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
      begin
        enabled = @browser.checked?(xp)
      rescue
        failure
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
      opt_str = opt.to_s
      pass_if @browser.element?("xpath=#{opt_str}")
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
      rescue
        failure
      else
        return selected == option
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
      fail_on_exception do
        @browser.wait_for_page_to_load(seconds)
      end
    end


    # A generic way to fill in any field, of any type.  (Just about.)
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
    #   Label, name, or id of the field control.  Identification by
    #   non-Selenium methods may not work for some links and buttons.
    # @param [String] value
    #   Value you want to set the field to.  (Default: empty string.)
    #   Recognized, case-insensitive values to turn a checkbox on are:
    #   * [empty string]
    #   * Check
    #   * Checked
    #   * On
    #   * True
    #   * Yes
    #
    # @since 0.1.1
    #
    def set_field(locator, value='', scope={})
      return skip_status if skip_step?
      begin
        # First, use Javascript to find out what the field is.
        loceval = loc(locator, 'field', scope)
        tagname = @browser.get_eval('this.browserbot.findElement("'+loceval+'").tagName+"."+this.browserbot.findElement("'+loceval+'").type').downcase

        case tagname
        when 'input.text', /^textarea\./
          return type_into_field(value, loceval)
        when 'input.radio'
          return select_radio(loceval)
        when 'input.checkbox'
          return enable_checkbox(loceval) if /^(yes|true|on|check(ed)?|)$/i === value
          return disable_checkbox(loceval)
        when /^select\./
          return select_from_dropdown(value, loceval)
        when /^(a|button)\./,'input.button','input.submit','input.image','input.reset'
          return click(loceval)
        else
          #raise ArgumentError, "Unidentified field #{locator}."
          return failure
        end
      rescue
        failure
      end
    end


    # Set a value (with #{set_field}) in the named field, based on the given
    # name/value pairs.  Uses #{escape_for_hash} to allow certain characters in
    # FitNesse. 
    #
    # @param [String] field
    #   A Locator or a name listed in the ids hash below.  If a name listed in
    #   the ids below, this field is case-insensitive.
    # @param [String] value
    #   Plain text to go into a field
    # @param ids
    #   A hash mapping common names to Locators.  (Optional, but redundant without it)
    #   The hash keys are case-insensitive.
    #
    # @since 0.1.1
    def set_field_among(field, value, ids={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field.  Fix it.
      ids = {} if ids == ""

      # Ignore case in the hash.
      ids.keys.each { |key| ids[escape_for_hash(key.to_s.downcase)] = ids[key] unless key.to_s.downcase == key }

      if ids[field.downcase] then
        return set_field(escape_for_hash(ids[field.downcase]), value, scope)
      else
        return set_field(field, value, scope)
      end
    end

    # Set values (with #{set_field}) in the named fields of a hash, based on the
    # given name/value pairs.  Uses #{escape_for_hash} to allow certain
    # characters in FitNesse. Note: Order of entries is not guaranteed, and
    # depends on the version of Ruby on your server!
    #
    # @param fields
    #   A key-value hash where the keys are Locators (case-sensitive) and the
    #   values are the string values you want in the fields.
    #
    # @since 0.1.1
    def set_fields(fields={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field.  Fix it.
      fields = {} if fields == ""
      fields.keys.each { |field| return failure unless set_field(escape_for_hash(field.to_s), escape_for_hash(fields[field]), scope) }
      return true
    end

    # Set values (with #{set_field}) in the named fields, based on the given
    # name/value pairs, and with mapping of names in the ids field.  Uses
    # #{escape_for_hash} to allow certain characters in FitNesse.
    # Note: Order of entries is not guaranteed, and depends on the
    # version of Ruby on your server!
    #
    # @param fields
    #   A key-value hash where the keys are keys of the ids hash
    #   (case-insensitive), or Locators (case-sensitive),
    #   and the values are the string values you want in the fields.
    # @param ids
    #   A hash mapping common names to Locators.  (Optional, but redundant
    #   without it)  The hash keys are case-insensitive.
    #
    # @example
    #   Suppose you have a nasty form whose fields have nasty locators.
    #   Suppose further that you want to fill in this form, many times, filling
    #   in different fields different ways.
    #   Begin by creating a Scenario table:
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
    def set_fields_among(fields={}, ids={}, scope={})
      return skip_status if skip_step?
      # FitNesse passes in "" for an empty field.  Fix it.
      ids = {} if ids == ""
      fields = {} if fields == ""

      # Ignore case in the hash.  set_field_among does this too, but doing it
      # just once this way is faster.
      ids.keys.each do |key|
        unless key.to_s.downcase == key then
          ids[escape_for_hash(key.to_s.downcase)] = ids[key]
          ids.delete(key)
        end
      end
      fields.keys.each { |field| return failure unless set_field_among(escape_for_hash(field.to_s), escape_for_hash(fields[field]), ids, scope) }
      return true
    end


    # Invoke a missing method. If a method is called on a SeleniumTest
    # instance, and that method is not explicitly defined, this method
    # will check to see whether the underlying Selenium::Client::Driver
    # instance can respond to that method. If so, that method is called
    # instead.
    #
    # @since 0.0.6
    #
    def method_missing(method, *args, &block)
      return skip_status if skip_step?
      if @browser.respond_to?(method)
        begin
          result = @browser.send(method, *args, &block)
        rescue
          failure
        else
          # The method call succeeded; did it return true or false?
          return result if [true, false].include? result
          # Not a Boolean return value--assume passing
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
    def respond_to?(method, include_private=false)
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
    # | If I see | pop-over ad |
    # | Click | Close | button |
    # | End if |
    #
    # @since 0.1.1
    def if_i_see(text)
      return false if aborted?
      # If this if is inside a block that's not running, record that.
      if !@conditional_stack.last then
        @conditional_stack.push nil
        return nil
      end

      # Test the condition.
      @conditional_stack.push @browser.text?(text)

      return true if @conditional_stack.last == true
      return nil if @conditional_stack.last == false
      return failure
    end

    # If the given parameter is "yes" or "true", do the steps until I see an
    # otherwise or end_if.  Otherwise do not do those steps.
    #
    # @param [String] text
    #   A string. "Yes" or "true" (case-insensitive) cause the following steps
    #   to run. Anything else does not.
    #
    # @example
    # | If parameter | ${spam_me} |
    # | Enable | Send me spam | checkbox |
    # | See | Email: | within | 10 | seconds |
    # | Type | ${spam_me_email} | into field | spammable_email |
    # | End if |
    #
    # @since 0.1.1
    def if_parameter(text)
      return false if aborted?
      if !@conditional_stack.last then
        @conditional_stack.push nil
        return nil
      end

      # Test the condition.
      @conditional_stack.push /^(yes|true)$/i === text

      return true if @conditional_stack.last == true
      return nil if @conditional_stack.last == false
      return failure
    end

    # End an if block.
    #
    # @since 0.1.1
    def end_if
      return false if aborted?
      # If there was no prior matching if, fail.
      return failure if @conditional_stack.length <= 1

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
    def otherwise
      return false if aborted?
      # If there was no prior matching if, fail.
      return failure if @conditional_stack.length <= 1

      # If this otherwise is within an un-executed if block, don't execute it.
      return nil if @conditional_stack.last == nil

      last_stack = @conditional_stack.pop
      @conditional_stack.push !last_stack
      return true if @conditional_stack.last == true
      return nil if @conditional_stack.last == false
      return failure
    end


    private

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
        failure
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
    def failure
      @found_failure = true
      return false
    end


    # Pass if the given condition is true; otherwise, fail with {#failure}.
    #
    # @since 0.0.6
    #
    def pass_if(condition)
      if condition
        return true
      else
        failure
      end
    end

    # Escape certain characters to generate characters that can't otherwise be used in FitNesse hashtables.
    # * \; becomes :
    # * \' becomes ,
    # * \[ becomes {
    # * \] becomes }
    # * \\ becomes \
    #
    # @since 0.1.1
    #
    def escape_for_hash(text)
      # ((?:\\\\)*) allows any extra pairs of "\"s to be saved.
      text = text.gsub(/(^|[^\\])\\((?:\\\\)*);/, '\1\2:')
      text = text.gsub(/(^|[^\\])\\((?:\\\\)*)'/, '\1\2,')
      text = text.gsub(/(^|[^\\])\\((?:\\\\)*)\[/, '\1\2{')
      text = text.gsub(/(^|[^\\])\\((?:\\\\)*)\]/, '\1\2}')
      text = text.gsub(/\\\\/, '\\')
      return text
    end

    # Conditionals

    # Should the current step be skipped, either because the test was aborted or
    # because we're in a conditional?
    #
    # @since 0.1.1
    def skip_step?
      return aborted? || !@conditional_stack.last
    end

    # Presuming the current step should be skipped, what status should I return?
    #
    # @since 0.1.1
    def skip_status
      return false if aborted?
      return nil if !@conditional_stack.last
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

