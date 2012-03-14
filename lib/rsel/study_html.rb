require 'rubygems'
require 'nokogiri'
require 'rsel/support'

module Rsel
  # Class to study a web page: Parses it with Nokogiri, and allows searching and simplifying Selenium-like expressions.
  class StudyHtml

    include Support

    # A large sentinel for @dirties.
    NO_PAGE_LOADED = 1000000

    def initialize(first_page=nil)
      @sections_kept_clean = []
      if first_page
        study(first_page)
      else
        @studied_page = nil
        # Invariant: @dirties == 0 while @keep_clean is true.
        @keep_clean = false
        # No page is loaded.  Set a large sentinel value so it's never tested.
        @dirties = NO_PAGE_LOADED
      end
    end

    # Load a page to study.
    #
    # @param [String] page
    #   Any argument that works for Nokogiri::HTML.  Often HTML in a string, or a path to a file.
    # @param [Boolean] keep
    #   Sets {#keep_clean} with this argument.  Default is false, so study(), by default, turns off keep_clean.
    def study(page, keep=false)
      @sections_kept_clean = []
      begin
        @studied_page = Nokogiri::HTML(page)
        @dirties = 0
      rescue => e
        @keep_clean = false
        @dirties = NO_PAGE_LOADED
        @studied_page = nil
        raise e
      end
      @keep_clean = keep
    end

    # "Dirty" the studied page, marking one (potential) change since the page was studied.
    # This can be undone: see {#undo_last_dirty}
    # Does nothing if {#keep_clean} has been called with true, which may occur from {#study}
    def dirty
      @dirties += 1 unless @keep_clean
    end

    # Try to un-{#dirty} the studied page by marking one (potential) change since the page was studied not actually a change.
    # This may or may not be enough to resume using the studied page.  Cannot be used preemptively.
    def undo_last_dirty
      @dirties -= 1 unless @dirties <= 0
    end

    # Try to un-{#dirty} the studied page.  Returns true on success or false if there was no page to clean.
    def undo_all_dirties
      if @studied_page != nil
        @dirties = 0
      else
        @keep_clean = false
        @dirties = NO_PAGE_LOADED
      end
      return @dirties == 0
    end

    # Return whether the studied page is clean and ready for analysis.  Not a verb - does not {#undo_all_dirties}.
    def clean?
      return @dirties == 0
    end
    #alias_method :clean, :clean?

    # Turn on or off maintenance of clean status.  True prevents {#dirty} from having any effect.
    # Also cleans all dirties (with {#undo_all_dirties}) if true, or dirties the page (with {#dirty}) if false.
    def keep_clean(switch)
      if switch
        if undo_all_dirties
          @keep_clean = true
          return true
        else
          return false
        end
      else
        @keep_clean = false
        dirty
        return true
      end
    end

    # Return whether keep_clean is on or not.  Useful if you want to start keeping clean and then return to your previous state.
    # Invariant: clean? == true if keeping_clean? == true.
    def keeping_clean?
      return @keep_clean
    end

    # Store the current keep_clean status, and begin forcing study use until the
    # next {#end_section}.  
    # A semi-optional block argument returns the first argument to give to {#study}.
    # It's not required if {#clean?}, but otherwise if it's not present an exception
    # will be thrown.
    def begin_section
      last_keep_clean = @keep_clean
      if clean?
        @keep_clean = true
      else
        # This will erase all prior sections.
        study(yield, true)
      end
      @sections_kept_clean.push(last_keep_clean)
    end

    # Restore the keep_clean status from before the last {#begin_section}.
    # Also marks the page dirty unless the last keep_clean was true.
    # It's fine to call this more than you call begin_section.  It will act just
    # like keep_clean(false) if it runs out of stack parameters.
    def end_section
      # Can't just assign - what if nil is popped?
      if @sections_kept_clean.pop
        @keep_clean = true
      else
        @keep_clean = false
        dirty
      end
      return true
    end

    # Simplify a Selenium-like locator (xpath or a css path), based on the studied page
    # 
    # @param [Boolean] x
    # @param [Boolean] tocss
    #   Return a css= path as a last resort?  Defaults to true.
    def simplify_locator(locator, tocss=true)
      return locator if @dirties > 0

      # We need a locator using either a css= or locator= expression.
      if locator[0,4] == 'css='
        studied_node = @studied_page.at_css(locator[4,locator.length])
        # If we're already using a css path, don't bother simplifying it to another css path.
        tocss = false
      elsif locator[0,6] == 'xpath=' || locator[0,2] == '//'
        locator = 'xpath='+locator if locator[0,2] == '//'
        studied_node = @studied_page.at_xpath(locator[6,locator.length])
      else
        # Some other kind of locator.  Just return it.
        return locator
      end
      # If the path wasn't found, just return the locator; maybe the browser will
      # have better luck.  (Or return a better error message!)
      return locator if studied_node == nil

      # Now let's try simplified locators.  First, id.
      return "id=#{studied_node['id']}" if(studied_node['id'] &&
                                           @studied_page.at_xpath("//*[@id='#{studied_node['id']}']") == studied_node)
      # Next, name.  Same pattern.
      return "name=#{studied_node['name']}" if(studied_node['name'] &&
                                               @studied_page.at_xpath("//*[@name='#{studied_node['name']}']") == studied_node)
      # Finally, try a CSS path.  Make that a simple xpath, since nth-of-type doesn't work.  But give up if we were told not to convert to CSS.
      return locator unless tocss
      return "xpath=#{studied_node.path}"
    end

    # Find a studied node by almost any type of Selenium locator.  Returns a Nokogiri::Node, or nil if not found.
    def get_node(locator)
      return nil if @dirties > 0
      case locator
      when /^id=/, /^name=/
        locator = locator.gsub("'","\\\\'").gsub(/([a-z]+)=([^ ]*) */, "[@\\1='\\2']")
        locator = locator.sub(/\]([^ ]+) */, "][@value='\\1']")
        return @studied_page.at_xpath("//*#{locator}")
      when /^link=/
        # Parse the link through loc (which may simplify it to an id or something).
        # Then try get_studied_node again.  It should not return to this spot.
        return get_node(loc(locator[5,locator.length], 'link'))
      when /^css=/
        return @studied_page.at_css(locator[4,locator.length])
      when /^xpath=/, /^\/\//
        return @studied_page.at_xpath(locator.sub(/^xpath=/,''))
      when /^dom=/, /^document\./
        # Can't parse dom=
        return nil
      else
        locator = locator.sub(/^id(entifier)?=/,'')
        retval = @studied_page.at_xpath("//*[@id='#{locator}']")
        retval = @studied_page.at_xpath("//*[@name='#{locator}']") unless retval
        return retval
      end
    end
  end
end
