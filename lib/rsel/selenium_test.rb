require File.join(File.dirname(__FILE__), 'selenium')

module Rsel
  class SeleniumTest
    # Start up a test, connecting to the given Selenium server and opening
    # a browser.
    #
    # @param [String] url
    #   Full URL, including http://, of the system under test
    # @param [String] server
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
    def initialize(url, server='localhost', port='4444', browser='*firefox')
      @selenium = Selenium::SeleniumDriver.new(server, port, browser, url)
      @selenium.start
      return true
    end

    # Close the browser window
    #
    # @example
    #   | close browser |
    #
    def close_browser
      @selenium.stop
      return true
    end


    # ----------------------------------------
    # Navigation
    # ----------------------------------------

    # Load a URL in the browser. The URL may be absolute or relative.
    #
    # @example
    #   | visit | http://www.automation-excellence.com |
    #   | visit | /software |
    #
    def visit(url)
      @selenium.open(url)
      return true
    end

    #this is intermittent in IE, works fine in firefox -Dale
    # Sample Call-> |ClickBack|
    def click_back(params)
      @selenium.go_back
    end

    # Sample Call-> |RefreshPage|
    def refresh_page
      @selenium.refresh
    end


    # ----------------------------------------
    # Verification
    # ----------------------------------------

    # Ensure that the given text appears on the current page.
    #
    # @example
    #   | should see | Welcome, Marcus |
    #
    def should_see(text)
      return @selenium.is_text_present(text)
    end

    # Ensure that the current page has the given title text.
    #
    # @example
    #   | should see title | Our Homepage |
    #   | should see | Our Homepage | title |
    #
    def should_see_title(title)
      if @selenium.get_title == title then
        return true
      else
        return false
      end
    end


    # ----------------------------------------
    # Entering text
    # ----------------------------------------

    # Type a value into the given field
    #
    # @param [String] text
    #   What to type into the field
    # @param [String] locator
    #   Locator string for the field you want to type into
    #
    # @example
    #   | type | Dale | into field | First name |
    #   | type | Dale | into | First name | field |
    #
    def type_into_field(text, locator)
      @selenium.type(get_locator(locator, textFieldLocators), text)
      return true
    end


    # ----------------------------------------
    # Clicking things
    # ----------------------------------------

    # Click on a link.
    #
    # @example
    #   | click | Logout | link |
    #   | click link | Logout |
    #
    def click_link(locator)
      begin
        @selenium.click(get_locator(locator, linkLocators))
      rescue
        @selenium.click("Link=#{locator}")
      end
    end

    # Press a button.
    #
    # @example
    #   | click | Login | button |
    #   | click button | Login |
    #
    def click_button(locator)
      @selenium.click(get_locator(locator, buttonLocators))
    end

    # Check or uncheck a checkbox.
    #
    # @example
    #   | click | Send me spam | checkbox |
    #   | click checkbox | Send me spam |
    #
    def click_checkbox(locator)
      @selenium.click(get_locator(locator, checkboxLocators))
    end

    # Click on an image.
    #
    # @example
    #   | click | colorado.png | image |
    #   | click image | colorado.png |
    #
    def click_image(locator)
      @selenium.click(get_locator(locator, imageLocators))
    end

    # Click on a radiobutton.
    #
    # @example
    #   | click | female | radio |
    #   | click radio | female |
    def click_radio(locator)
      @selenium.click(get_locator(locator, radioLocators))
    end



    # ----------------------------------------
    # Waiting
    # ----------------------------------------

    # Wait a certain number of seconds before continuing
    #
    # @example
    #   | wait | 5 | seconds |
    #
    def wait_seconds(seconds)
      sleep seconds.to_i
    end


    # ----------------------------------------
    # Form stuff
    # ----------------------------------------

    #added 7/7 -Dale (parm[0] is menu, parm[1] is value)
    # Sample Call-> |UserSelects|my menu|Option|value=40|
    def select_from_dropdown(value, locator)
      @selenium.select(locator, value)
    end

    #added 7/8 -Dale (use form name or form action for parameter)
    # Sample Call-> |UserSubmitsForm|My form name|
    def submit_form(locator)
      @selenium.submit(get_locator(locator, formLocators))
    end

    # ----------------------------------------
    # Miscellaneous
    # ----------------------------------------

    #maximize works in IE but not firefox -Dale
    # Sample Call-> |WindowMaximize|
    def maximize_window
      @selenium.window_maximize
    end

    # Sample Call-> |PageReloadsInLessThan|30|Seconds|
    def page_reloads_in_less_than_seconds(seconds)
      return @selenium.wait_for_page_to_load(seconds + "000")
    end

    def capitalizeEachWord(str)
      return str.gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase }
    end

    #there may be a better way but I want to be able to insert comments now -Dale
    # Sample Call-> |Comment|this is a comment|
    def comment(*ignore_cells)
      return
    end


    # ----------------------------------------
    # Helper functions
    # ----------------------------------------

    def get_locator(caption, possibleFormats)
      possibleCaptions = getPossibleCaptions(caption)
      possibleCaptions.each do |possibleCaption|
        possibleFormats.each do |possibleFormat|
          locator = possibleFormat.sub('{0}', possibleCaption)
          puts "possible locator: " + locator
          if @selenium.is_element_present(locator)
            return locator
          end
        end
      end
      raise "No Locator Found"
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

    def textFieldLocators
      [
        "xpath=//input[@type='text' and @name='{0}']",
        "xpath=//input[@type='text' and @title='{0}']",
        "xpath=//input[@type='password' and @name='{0}']",
        "xpath=//textarea[@name='{0}']",
        "xpath=//input[@type='text' and @id='{0}']",
        "xpath=//input[@type='password' and @id='{0}']",
        "xpath=//textarea[@id='{0}']",
      ]
    end

    def buttonLocators
      [
        "xpath=//input[@type='submit' and @name='{0}']",
        "xpath=//input[@type='button' and @name='{0}']",
        "xpath=//input[@type='submit' and @value='{0}']",
        "xpath=//input[@type='button' and @value='{0}']",
        "xpath=//input[@type='submit' and @id='{0}']",
        "xpath=//input[@type='button' and @id='{0}']",
      ]
    end

    def checkboxLocators
      [
        "xpath=//input[@type='checkbox' and @name='{0}']",
        "xpath=//span[@id='{0}']/span/button",
        "xpath=//span[@type='checkbox' and @id='{0}']/span/button",
        "xpath=//input[@type='checkbox' and @label[text()='{0}']]",
        "xpath=//input[@type='checkbox' and @id=(//label[text()='{0}']/@for)]",
      ]
    end

    #added 7/1/08 -Dale; bug fix 7/7
    def radioLocators
      [
        "xpath=//input[@type='radio' and @name='{0}']",
        "xpath=//input[@type='radio' and @id='{0}']",
        "xpath=//input[@type='radio' and @label[text()='{0}']]",
        "xpath=//input[@type='radio' and @id=(//label[text()=' {0}']/@for)]",
        "xpath=//input[@type='radio' and @id=(//label[text()='{0} ']/@for)]",
        "xpath=//input[@type='radio' and @id=(//label[text()='{0}']/@for)]",
      ]
    end

    # added 2nd and 3rd xpaths because leading or trailing space may exist for the text of links
    # added title and class 7/9 -Dale
    def linkLocators
      [
        "xpath=//a[text()='{0}']",
        "xpath=//a[text()=' {0}']",
        "xpath=//a[text()='{0} ']",
        "xpath=//a[@href='{0}']",
        "xpath=//a[@title='{0}']",
        "xpath=//a[@class='{0}']",
      ]
    end

    # added to verify image elements -Dale
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

    #added 7/8 -Dale
    def formLocators
      [
        "xpath=//form[@action='{0}']",
        "xpath=//form[@class='{0}']",
        "xpath=//form[@name='{0}']",
        "xpath=//form[@legend[text()='{0}']]",
      ]
    end

    # added 7/8 -Dale
    def dragdropLocators
      [
        "xpath=//div[@id='{0}']",
        "xpath=//img[@alt='{0}']",
        "xpath=//img[@src='{0}']",
      ]
    end

    #added 7/8 -Dale (use locator and offset e.g., "+70, -300"
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

    #added return value for text found or not - 6/26/08
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


    ####################################################
    #DEBUG - all functions after this point are in a debug state - Dale
    ####################################################

    def ChooseOKNextConfirmation(selenium,params)
        selenium.choose_ok_on_next_confirmation
    end
    def ChooseCancelNextConfirmation(selenium,params)
        selenium.choose_cancel_on_next_confirmation
    end

    #-need to add functionality to select window before closing
    def CloseWindow(selenium,params)
        selenium.close
    end

    def SelectWindow(selenium,params)
        windowIDs=selenium.get_all_window_ids()
        windowIDs.each{|id| puts "id="+id}
        windowNames=selenium.get_all_window_names()
        windowNames.each{|name| puts "name="+name}
        windowTitles=selenium.get_all_window_titles()
        windowTitles.each{|title| puts "title="+title}
        selenium.select_window(params[0])
    end

    def FocusWindow(selenium,params)
      selenium.window_focus()
    end

    def OpenURLOnWindow(selenium,params)
      selenium.open_window(params[0],params[1])
    end


    #def GetAllLinks(selenium,params)
    #   return selenium.get_all_links
    #end

    #def GetTitle(selenium,params)
    #    return selenium.get_title
    #    #return get_string_array("getAllLinks", [])
    #end

  end
end



