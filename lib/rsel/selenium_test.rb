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
    #   | refresh page |
    #
    def refresh_page
      return_error_status do
        @browser.refresh
      end
    end


    # Maximize the browser window. May not work in some browsers.
    #
    # @example
    #   | maximize browser |
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


    # Type a value into the given field.
    #
    # @param [String] text
    #   What to type into the field
    # @param [String] locator
    #   Label, name, or id of the field you want to type into
    #
    # @example
    #   | Type | Dale | into field | First name |
    #   | Type | Dale | into | First name | field |
    #
    def type_into_field(text, locator)
      return_error_status do
        @browser.type("xpath=#{XPath::HTML.field(locator)}", text)
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
      @browser.field("xpath=#{XPath::HTML.field(locator)}").include?(text)
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
      @browser.field("xpath=#{XPath::HTML.field(locator)}") == text
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
        @browser.click("xpath=#{XPath::HTML.link_or_button(locator)}",
                       :wait_for => :page)
      end
    end


    # Click on a link.
    #
    # @param [String] locator
    #   Link text or id of the anchor element
    #
    # @example
    #   | Click | Logout | link |
    #   | Click link | Logout |
    #
    def click_link(locator)
      return_error_status do
        @browser.click("xpath=#{XPath::HTML.link(locator)}",
                      :wait_for => :page)
      end
    end


    # Alias for {#click_link}.
    #
    # @example
    #   | Follow | Logout |
    #
    def follow(locator)
      click_link(locator)
    end


    # Press a button.
    #
    # @param [String] locator
    #   Button text, value, or id of the button
    #
    # @example
    #   | Click | Login | button |
    #   | Click button | Login |
    #
    def click_button(locator)
      return_error_status do
        @browser.click("xpath=#{XPath::HTML.button(locator)}",
                      :wait_for => :page)
      end
    end


    # Alias for {#click_button}
    #
    # @example
    #   | Press | Search |
    #
    def press(locator)
      click_button(locator)
    end


    # Enable (check) a checkbox.
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to check
    #
    # @example
    #   | Enable | Send me spam | checkbox |
    #   | Enable checkbox | Send me spam |
    #
    def enable_checkbox(locator)
      return_error_status do
        @browser.check("xpath=#{XPath::HTML.checkbox(locator)}")
      end
    end


    # Disable (uncheck) a checkbox.
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to uncheck
    #
    # @example
    #   | Disable | Send me spam | checkbox |
    #   | Disable checkbox | Send me spam |
    #
    def disable_checkbox(locator)
      return_error_status do
        @browser.uncheck("xpath=#{XPath::HTML.checkbox(locator)}")
      end
    end


    # Verify that a given checkbox or radiobutton is enabled (checked)
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to inspect
    #
    # @example
    #   | Checkbox is enabled | send me spam |
    #   | Checkbox | send me spam | is enabled |
    #
    def checkbox_is_enabled(locator)
      begin
        enabled = @browser.checked?("xpath=#{XPath::HTML.checkbox(locator)}")
      rescue
        return false
      else
        return enabled
      end
    end


    # Verify that a given checkbox or radiobutton is disabled (unchecked)
    #
    # @param [String] locator
    #   Label, value, or id of the checkbox to inspect
    #
    # @example
    #   | Checkbox is disabled | send me spam |
    #
    def checkbox_is_disabled(locator)
      begin
        enabled = @browser.checked?("xpath=#{XPath::HTML.checkbox(locator)}")
      rescue
        return false
      else
        return !enabled
      end
    end


    # Select a radio button.
    #
    # @param [String] locator
    #   Label, id, or name of the radio button to select
    #
    # @example
    #   | Select | female | radio |
    #   | Select radio | female |
    #
    def select_radio(locator)
      return_error_status do
        @browser.click("xpath=#{XPath::HTML.radio_button(locator)}")
      end
    end


    # Alias for {#checkbox_is_disabled}
    #
    # @example
    #   | Radio is disabled | medium |
    #   | Radio | medium | is disabled |
    #
    def radio_is_disabled(locator)
      checkbox_is_disabled(locator)
    end


    # Alias for {#checkbox_is_enabled}
    #
    # @example
    #   | Radio is enabled | medium |
    #   | Radio | medium | is enabled |
    #
    def radio_is_enabled(locator)
      checkbox_is_enabled(locator)
    end


    # Click on an image.
    #
    # @param [String] locator
    #   The id, src, title, or href of the image to click on
    #
    # @example
    #   | Click | colorado.png | image |
    #   | Click image | colorado.png |
    #
    def click_image(locator)
      return_error_status do
        @browser.click(get_locator(locator, imageLocators))
      end
    end


    # Select a value from a dropdown/combo box.
    #
    # @param [String] value
    #   The value to choose from the dropdown
    # @param [String] locator
    #   Label, name, or id of the dropdown
    #
    # @example
    #   | select | Tall | from | Height | dropdown |
    #   | select | Tall | from dropdown | Height |
    #
    def select_from_dropdown(value, locator)
      return_error_status do
        @browser.select("xpath=#{XPath::HTML.select(locator)}", value)
      end
    end


    # Submit the form with the given name.
    #
    # @param [String] locator
    #   Form id, name or action
    #
    # @example
    #   | submit form | place_order |
    #   | submit | place_order | form |
    #
    def submit_form(locator)
      @browser.submit(get_locator(locator, formLocators))
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
        @browser.wait_for_page_to_load("#{seconds}000")
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


    # TODO: Clean up / refactor the stuff below

    def capitalizeEachWord(str)
      return str.gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase }
    end

    def get_locator(caption, possibleFormats)
      possibleCaptions = getPossibleCaptions(caption)
      possibleCaptions.each do |possibleCaption|
        possibleFormats.each do |possibleFormat|
          locator = possibleFormat.sub('{0}', possibleCaption)
          puts "possible locator: " + locator
          if @browser.is_element_present(locator)
            return locator
          end
        end
      end
      raise LocatorNotFound, "Could not find locator '#{caption}'"
    end

    # possible variations on the caption to look for
    def getPossibleCaptions(caption)
      possibleCaptions = Array.new
      possibleCaptions[0] = caption
      possibleCaptions[1] = ' ' + caption
      possibleCaptions[2] = caption + ' '
      possibleCaptions[3] = capitalizeEachWord(caption)
      possibleCaptions[4] = ' ' + capitalizeEachWord(caption)
      possibleCaptions[5] = capitalizeEachWord(caption) + ' '
      return possibleCaptions
    end

    def imageLocators
      [
        "xpath=//img[@alt='{0}']",
        "xpath=//img[@title='{0}']",
        "xpath=//img[@id='{0}']",
        "xpath=//img[@href='{0}']",
        "xpath=//img[@src='{0}']",
        "xpath=//input[@type='image' and @src='{0}']",
        "xpath=//input[@type='image' and @id='{0}']",
        "xpath=//input[@type='image' and @alt='{0}']",
      ]
    end

    def formLocators
      [
        "xpath=//form[@action='{0}']",
        "xpath=//form[@class='{0}']",
        "xpath=//form[@name='{0}']",
        "xpath=//form[@legend[text()='{0}']]",
      ]
    end

    def dragdropLocators
      [
        "xpath=//div[@id='{0}']",
        "xpath=//img[@alt='{0}']",
        "xpath=//img[@src='{0}']",
      ]
    end

    # Sample Call-> |UserDrags|slider name|AndDrops|-10, 0|
    def UserDragsAndDrops(selenium,params)
      selenium.drag_and_drop(get_locator(selenium,params[0],dragdropLocators), params[1])
    end

    # Sample Call-> |VerifyText|my image|
    def VerifyImage(selenium,params)
        if selenium.is_element_present(get_locator(selenium,params[0],imageLocators)) then
          return "right"
        else
          return "wrong"
        end
    end

    # Sample Call-> |WaitUpTo|30|SecondsToVerifyImage|my image|
    def WaitUpToSecondsToVerifyImage(selenium,params)
      count=0
      retval = "wrong"
      while (count<params[0].to_i)
        if selenium.is_element_present(get_locator(selenium,params[1],imageLocators)) then
          retval = "right"
          break
        end
        sleep 1
        count=count+1
      end
      return retval
    end

    # Sample Call-> |WaitUpTo|30|SecondsToVerifyText|my text|
    def WaitUpToSecondsToVerifyText(selenium,params)
      count=0
      retval = "wrong"
      while (count<params[0].to_i)
        if selenium.is_text_present(params[1]) then
          retval = "right"
          break
        end
        sleep 1
        count=count+1
      end
      return retval
    end

  end
end



