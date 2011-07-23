require File.join(File.dirname(__FILE__), 'exceptions')

require 'rubygems'
require 'xpath'
require 'selenium/client'

module Rsel

  # Main Selenium-test class.
  #
  # @example
  #   !| script | selenium test | http://www.example.com/ |
  #
  # NOTE: Function names beginning with these words are forbidden:
  #
  # - check
  # - ensure
  # - reject
  # - note
  # - show
  # - start
  #
  # This is because the above words are keywords in Slim script tables; if
  # the first cell of a script table begins with any of these words, Slim tries
  # to apply special handling to them, which usually doesn't do what you want.
  #
  class SeleniumTest

    # Initialize a test, connecting to the given Selenium server.
    #
    # @param [String] url
    #   Full URL, including http://, of the system under test
    # @param [String] host
    #   IP address or hostname where selenium-server is running
    # @param [String] port
    #   Port number of selenium-server
    # @param [String] browser
    #   Which browser to test with
    #
    # @example
    #   | script | selenium test | http://site.to.test/ |
    #   | script | selenium test | http://site.to.test/ | 192.168.0.3 | 4445 |
    #
    def initialize(url, host='localhost', port='4444', browser='*firefox')
      @url = url
      @browser = Selenium::Client::Driver.new(
        :host => host,
        :port => port,
        :browser => browser,
        :url => url)
    end

    attr_reader :url, :browser


    # Start the session and open a browser to the URL defined at the start of
    # the test.
    #
    # @example
    #   | Open browser |
    #
    def open_browser
      begin
        @browser.start_new_browser_session
      rescue
        # TODO: Find a way to make the test abort here
        raise SeleniumNotRunning, "Could not start Selenium."
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
      return_error_status do
        @browser.open(path_or_url)
      end
    end


    # Click the Back button to navigate to the previous page.
    #
    # @example
    #   | Click back |
    #
    def click_back
      return_error_status do
        @browser.go_back
      end
    end


    # Reload the current page.
    #
    # @example
    #   | Refresh page |
    #
    def refresh_page
      return_error_status do
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
      return @browser.text?(text)
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
      return !@browser.text?(text)
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
      return (@browser.get_title == title)
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
      return !(@browser.get_title == title)
    end


    # Ensure that a link exists on the page.
    #
    # @param [String] locator
    #   Text or id of the link, or image alt text
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Link | Logout | exists |
    #   | Link exists | Logout |
    #   | Link | Logout | exists | !{within:header} |
    #
    # @since 0.0.2
    #
    def link_exists(locator, options={})
      return @browser.element?(xpath('link', locator, options))
    end


    # Ensure that a button exists on the page.
    #
    # @param [String] locator
    #   Text, value, or id of the button
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Button | Search | exists |
    #   | Button exists | Search |
    #   | Button | Search | exists | !{within:members} |
    #
    # @since 0.0.2
    #
    def button_exists(locator, options={})
      return @browser.element?(xpath('button', locator, options))
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
    def row_exists(cells)
      row = XPath.descendant(:tr)[XPath::HTML.table_row(cells.split(/, */))]
      return @browser.element?("xpath=#{row.to_s}")
    end


    # Type a value into the given field.
    #
    # @param [String] text
    #   What to type into the field
    # @param [String] locator
    #   Label, name, or id of the field you want to type into
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Type | Dale | into field | First name |
    #   | Type | Dale | into | First name | field |
    #   | Type | Dale | into | First name | field | !{within:contact} |
    #
    def type_into_field(text, locator, options={})
      return_error_status do
        @browser.type(xpath('field', locator, options), text)
      end
    end


    # Fill in a field with the given text.
    #
    # @param [String] locator
    #   Label, name, or id of the field you want to type into
    # @param [String] text
    #   What to type into the field
    #
    # @example
    #   | Fill in | First name | with | Eric |
    #
    def fill_in_with(locator, text)
      type_into_field(text, locator)
    end


    # Verify that a text field contains the given text.
    # The field may include additional text, as long as the
    # expected value is in there somewhere.
    #
    # @param [String] locator
    #   Label, name, or id of the field you want to inspect
    # @param [String] text
    #   Text to expect in the field
    #
    # @example
    #   | Field | First name | contains | Eric |
    #
    def field_contains(locator, text)
      @browser.field(xpath('field', locator)).include?(text)
    end


    # Verify that a text field's value equals the given text.
    # The value must match exactly.
    #
    # @param [String] locator
    #   Label, name, or id of the field you want to inspect
    # @param [String] text
    #   Text to expect in the field
    #
    # @example
    #   | Field | First name | equals | Eric |
    #
    def field_equals(locator, text)
      @browser.field(xpath('field', locator)) == text
    end


    # Click on a link or button, and wait for a page to load.
    #
    # @param [String] locator
    #   Text, value or id of the link or button to click
    #
    # @example
    #   | Click | Next   |
    #   | Click | Logout |
    #
    def click(locator)
      return_error_status do
        @browser.click(xpath('link_or_button', locator))
      end
    end


    # Click on a link.
    #
    # @param [String] locator
    #   Text or id of the link, or image alt text
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Click | Logout | link |
    #   | Click link | Logout |
    #   | Follow | Logout |
    #   | Click | Logout | link | !{within:header} |
    #
    def click_link(locator, options={})
      return_error_status do
        @browser.click(xpath('link', locator, options))
      end
    end
    alias_method :follow, :click_link


    # Press a button.
    #
    # @param [String] locator
    #   Text, value, or id of the button
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Click | Search | button |
    #   | Click button | Search |
    #   | Press | Login |
    #
    def click_button(locator, options={})
      # TODO: Make this fail when the button is disabled
      return_error_status do
        @browser.click(xpath('button', locator, options))
      end
    end
    alias_method :press, :click_button


    # Enable (check) a checkbox by clicking on it.
    # If the checkbox is already enabled, do nothing.
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to check
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Enable | Send me spam | checkbox |
    #   | Enable checkbox | Send me spam |
    #
    def enable_checkbox(locator, options={})
      return true if checkbox_is_enabled(locator)
      return_error_status do
        @browser.click(xpath('checkbox', locator, options))
      end
    end


    # Disable (uncheck) a checkbox by clicking on it.
    # If the checkbox is already disabled, do nothing.
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to uncheck
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Disable | Send me spam | checkbox |
    #   | Disable checkbox | Send me spam |
    #
    def disable_checkbox(locator, options={})
      return true if checkbox_is_disabled(locator)
      return_error_status do
        @browser.click(xpath('checkbox', locator, options))
      end
    end


    # Verify that a given checkbox or radiobutton is enabled (checked)
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to inspect
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Checkbox is enabled | send me spam |
    #   | Checkbox | send me spam | is enabled |
    #   | Radio is enabled | medium |
    #   | Radio | medium | is enabled |
    #
    def checkbox_is_enabled(locator, options={})
      begin
        enabled = @browser.checked?(xpath('checkbox', locator, options))
      rescue
        return false
      else
        return enabled
      end
    end
    alias_method :radio_is_enabled, :checkbox_is_enabled


    # Verify that a given checkbox or radiobutton is disabled (unchecked)
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to inspect
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Checkbox is disabled | send me spam |
    #   | Checkbox | send me spam | is disabled |
    #   | Radio is disabled | medium |
    #   | Radio | medium | is disabled |
    #
    def checkbox_is_disabled(locator, options={})
      begin
        enabled = @browser.checked?(xpath('checkbox', locator, options))
      rescue
        return false
      else
        return !enabled
      end
    end
    alias_method :radio_is_disabled, :checkbox_is_disabled


    # Select a radio button.
    #
    # @param [String] locator
    #   Label, id, or name of the radio button to select
    # @param [Hash] options
    #   Scoping keywords as understood by {#xpath}
    #
    # @example
    #   | Select | female | radio |
    #   | Select radio | female |
    #
    def select_radio(locator, options={})
      return_error_status do
        @browser.click(xpath('radio_button', locator, options))
      end
    end


    # Select an option from a dropdown/combo box.
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
    def select_from_dropdown(option, locator)
      return_error_status do
        @browser.select(xpath('select', locator), option)
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
    def dropdown_includes(locator, option)
      dropdown = XPath::HTML.select(locator)
      opt = dropdown[XPath::HTML.option(option)]
      opt_str = opt.to_s
      return @browser.element?("xpath=#{opt_str}")
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
    def dropdown_equals(locator, option)
      begin
        selected = @browser.get_selected_label(xpath('select', locator))
      rescue
        return false
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
      return_error_status do
        @browser.wait_for_page_to_load(seconds)
      end
    end


    # Execute the given block, and return false if it raises an exception.
    # Otherwise, return true.
    #
    # @example
    #   return_error_status do
    #     # some code that might raise an exception
    #   end
    #
    def return_error_status
      begin
        yield
      rescue => e
        #puts e.message
        #puts e.backtrace
        return false
      else
        return true
      end
    end


    # Return a Selenium-style xpath generated by calling `XPath::HTML.<kind>`
    # with the given `arg`.
    #
    # @param [String] kind
    #   What kind of locator you're using (link, button, checkbox, field etc.).
    #   This must correspond to a method name in `XPath::HTML`.
    # @param [String] arg
    #   Argument accepted by `XPath::HTML.<kind>`. Usually a locator, but may
    #   be something else depending on the method you're calling.
    # @param [Hash] options
    #   Additional options to restrict the scope of matching elements
    # @option options [String] :within
    #   Restrict scope to elements having this name or id, matching `locator`
    #   only if it's contained within an element with this name or id.
    #
    # @example
    #   xpath('link', 'Log in')
    #   xpath('button', 'Submit')
    #   xpath('field', 'First name')
    #   xpath('table_row', ['First', 'Last'])
    #
    def xpath(kind, locator, options={})
      loc_xp = XPath::HTML.send(kind, locator)
      if options[:within]
        parent = options[:within]
        scope = XPath.descendant[
          XPath.attr(:id).equals(parent) | XPath.attr(:name).equals(parent)]
        result = scope[loc_xp].to_s
      else
        result = loc_xp.to_s
      end
      return "xpath=#{result}"
    end

  end
end



