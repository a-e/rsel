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
    # @option options [String, Boolean] :stop_on_error
    #   `true` or `'true'` to raise an exception when a step fails,
    #   `false` or `'false'` to simply return false when a step fails
    #
    # @example
    #   | script | selenium test | http://site.to.test/ |
    #   | script | selenium test | http://site.to.test/ | !{host:192.168.0.3} |
    #   | script | selenium test | http://site.to.test/ | !{host:192.168.0.3, port:4445} |
    #   | script | selenium test | http://site.to.test/ | !{stop_on_error:true} |
    #
    def initialize(url, options={})
      # Strip HTML tags from URL
      @url = url.gsub(/<\/?[^>]*>/, '')
      @browser = Selenium::Client::Driver.new(
        :host => options[:host] || 'localhost',
        :port => options[:port] || 4444,
        :browser => options[:browser] || '*firefox',
        :url => @url)
      # Accept Booleans or strings, case-insensitive
      if options[:stop_on_error].to_s =~ /true/i
        @stop_on_error = true
      else
        @stop_on_error = false
      end
    end

    attr_reader :url, :browser, :stop_on_error
    attr_writer :stop_on_error


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
      pass_if !@browser.text?(text)
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
      begin
        field = @browser.field(loc(locator, 'field', scope))
      rescue => e
        failure e.message
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
      begin
        field = @browser.field(loc(locator, 'field', scope))
      rescue => e
        failure e.message
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
      xp = loc(locator, 'checkbox', scope)
      begin
        enabled = @browser.checked?(xp)
      rescue => e
        failure e.message
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
      xp = loc(locator, 'radio_button', scope)
      begin
        enabled = @browser.checked?(xp)
      rescue => e
        failure e.message
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
      xp = loc(locator, 'checkbox', scope)
      begin
        enabled = @browser.checked?(xp)
      rescue => e
        failure e.message
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
      xp = loc(locator, 'radio_button', scope)
      begin
        enabled = @browser.checked?(xp)
      rescue => e
        failure e.message
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
      begin
        selected = @browser.get_selected_label(loc(locator, 'select', scope))
      rescue => e
        failure e.message
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
      fail_on_exception do
        @browser.wait_for_page_to_load(seconds)
      end
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
      if @browser.respond_to?(method)
        begin
          result = @browser.send(method, *args, &block)
        rescue => e
          failure e.message
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


    private

    # Execute the given block, and return false if it raises an exception.
    # Otherwise, return true. If `@stop_on_error` is true, raise a
    # `StopTestStepFailed` exception instead of returning false.
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
        failure e.message
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
    def ensure_editable(selenium_locator)
      if @browser.is_editable(selenium_locator)
        return true
      else
        raise StopTestInputDisabled, "Input is not editable"
      end
    end


    # Indicate a failure by returning `false` or raising an exception.
    # If `@stop_on_error` is true, raise a `StopTestStepFailed` exception.
    # Otherwise, simply return false.
    #
    # @param [String] message
    #   Optional message to include in the exception.
    #   Ignored if `@stop_on_error` is false.
    #
    # @since 0.0.6
    #
    def failure(message='')
      if @stop_on_error
        raise StopTestStepFailed, message
      else
        return false
      end
    end


    # Pass if the given condition is true; otherwise, fail by calling
    # {#failure} with an optional `message`.
    #
    # @since 0.0.6
    #
    def pass_if(condition, message='')
      if condition
        return true
      else
        failure message
      end
    end

  end
end



