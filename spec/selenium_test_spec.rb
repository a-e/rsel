require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Rsel::SeleniumTest do
  before(:all) do
    @st = Rsel::SeleniumTest.new('http://localhost:8070/')
    @st.open_browser
  end

  after(:all) do
    @st.close_browser('without showing errors')
  end

  context "initialization" do
    before(:each) do
      @st.visit("/")
    end

    it "sets correct default configuration" do
      @st.url.should == "http://localhost:8070/"
      @st.browser.host.should == "localhost"
      @st.browser.port.should == 4444
    end
  end


  context "navigation" do
    before(:each) do
      @st.visit("/").should be_true
    end

    describe "#visit" do
      context "passes when" do
        it "page exists" do
          @st.visit("/about").should be_true
        end
      end

      # FIXME: Selenium server 2.3.0 and 2.4.0 no longer fail
      # when a 404 or 500 error is raised
      #context "fails when" do
        #it "page gets a 404 error" do
          #@st.visit("/404").should be_false
        #end
        #it "page gets a 500 error" do
          #@st.visit("/500").should be_false
        #end
      #end
    end

    context "reload the current page" do
      # TODO
    end

    describe "#click_back" do
      it "passes and loads the correct URL" do
        @st.visit("/about")
        @st.visit("/")
        @st.click_back.should be_true
        @st.see_title("About this site").should be_true
      end

      #it "fails when there is no previous page in the history" do
        # TODO: No obvious way to test this, since everything is running in the
        # same session
      #end
    end
  end # navigation


  context "visibility" do
    before(:each) do
      @st.visit("/").should be_true
    end

    describe "#see" do
      context "passes when" do
        it "text is present" do
          @st.see("Welcome").should be_true
          @st.see("This is a Sinatra webapp").should be_true
        end
      end

      context "fails when" do
        it "text is absent" do
          @st.errors
          @st.see("Nonexistent").should be_false
          @st.see("Some bogus text").should be_false
          @st.errors.should eq('')
        end
      end

      it "is case-sensitive" do
        @st.see("Sinatra webapp").should be_true
        @st.see("sinatra Webapp").should be_false
      end
    end

    describe "#do_not_see" do
      context "passes when" do
        it "text is absent" do
          @st.do_not_see("Nonexistent").should be_true
          @st.do_not_see("Some bogus text").should be_true
        end
      end

      context "fails when" do
        it "text is present" do
          @st.errors
          @st.do_not_see("Welcome").should be_false
          @st.do_not_see("This is a Sinatra webapp").should be_false
          @st.errors.should eq('')
        end
      end

      it "is case-sensitive" do
        @st.do_not_see("Sinatra webapp").should be_false
        @st.do_not_see("sinatra Webapp").should be_true
      end
    end
  end # visibility


  context "links" do
    before(:each) do
      @st.visit("/").should be_true
    end

    describe "#click" do
      context "passes when" do
        it "link exists" do
          @st.click("About this site").should be_true
        end
      end

      context "fails when" do
        it "link does not exist" do
          @st.click("Bogus link").should be_false
        end
      end
    end


    describe "#click_link" do
      context "passes when" do
        it "link exists" do
          @st.click_link("About this site").should be_true
        end

        it "link exists within scope" do
          @st.click_link("About this site", :within => "header").should be_true
        end

        it "link exists in table row" do
          @st.visit("/table")
          @st.click_link("Edit", :in_row => "Marcus").should be_true
          @st.see_title("Editing Marcus").should be_true
        end
      end

      context "fails when" do
        it "link does not exist" do
          @st.click_link("Bogus link").should be_false
        end

        it "link exists, but not within scope" do
          @st.click_link("About this site", :within => "footer").should be_false
        end

        it "link exists, but not in table row" do
          @st.visit("/table")
          @st.click_link("Edit", :in_row => "Ken").should be_false
        end
      end
    end

    describe "#link_exists" do
      context "passes when" do
        it "link with the given text exists" do
          @st.link_exists("About this site").should be_true
          @st.link_exists("Form test").should be_true
        end

        it "link with the given text exists within scope" do
          @st.link_exists("About this site", :within => "header").should be_true
          @st.link_exists("Form test", :within => "footer").should be_true
          @st.link_exists("Table test", :within => "footer").should be_true
        end
      end

      context "fails when" do
        it "no such link exists" do
          @st.link_exists("Welcome").should be_false
          @st.link_exists("Don't click here").should be_false
        end

        it "link exists, but not within scope" do
          @st.link_exists("About this site", :within => "footer").should be_false
          @st.link_exists("Form test", :within => "header").should be_false
          @st.link_exists("Table test", :within => "header").should be_false
        end
      end
    end
  end # links


  context "temporal visibility" do
    before(:each) do
      @st.visit("/slowtext").should be_true
    end

    describe "#see_within_seconds" do
      context "passes when" do
        it "text is already present" do
          @st.see("Late text page").should be_true
          @st.see_within_seconds("The text is coming...", 10).should be_true
        end
        it "text appears in time" do
          @st.see("The text is coming...").should be_true
          @st.do_not_see("The text is here!").should be_true
          @st.see_within_seconds("The text is here!", 10).should be_true
          @st.see("The text is here!").should be_true
        end
      end

      context "fails when" do
        it "text appears too late" do
          @st.see("The text is coming...").should be_true
          @st.do_not_see("The text is here!").should be_true
          @st.see_within_seconds("The text is here!", 1).should be_false
        end
        it "text never appears" do
          @st.see_within_seconds("Nonexistent", 5).should be_false
        end
      end

      it "is case-sensitive" do
        @st.see_within_seconds("The text is here!", 5).should be_true
        @st.see_within_seconds("The text IS HERE!", 5).should be_false
      end
    end

    describe "#do_not_see_within_seconds" do
      context "passes when" do
        it "text is already absent" do
          @st.see("Late text page").should be_true
          @st.do_not_see_within_seconds("Some absent text", 10).should be_true
        end
        it "text disappears in time" do
          @st.see_within_seconds("The text is here!", 10).should be_true
          @st.do_not_see_within_seconds("The text is here!", 10).should be_true
          @st.do_not_see("The text is here!").should be_true
        end
      end

      context "fails when" do
        it "text disappears too late" do
          @st.see_within_seconds("The text is here!", 10).should be_true
          @st.do_not_see_within_seconds("The text is here!", 1).should be_false
        end
        it "text never disappears" do
          @st.do_not_see_within_seconds("The text is coming...", 5).should be_false
        end
      end
    end
  end # temporal visibility


  context "conditionals" do
    before(:each) do
      @st.visit("/").should be_true
    end

    describe "#if_i_see" do
      context "passes when" do
        it "sees text" do
          @st.if_i_see("About this site").should be_true
          @st.click("About this site").should be_true
          @st.end_if.should be_true
        end

        it "is inside a passed block" do
          @st.if_i_see("About this site").should be_true
          @st.click("About this site").should be_true
          @st.page_loads_in_seconds_or_less(10).should be_true
          @st.if_i_see("This site is").should be_true
          @st.see("is really cool.").should be_true
          @st.end_if.should be_true
          @st.end_if.should be_true
        end
      end

      context "skips when" do
        it "does not see text" do
          @st.if_i_see("Bogus link").should be_nil
          @st.click("Bogus link").should be_nil
          @st.end_if.should be_true
        end

        it "is inside a skipped block" do
          @st.if_i_see("Bogus link").should be_nil
          @st.click("Bogus link").should be_nil
          @st.if_i_see("About this site").should be_nil
          @st.click("About this site").should be_nil
          @st.end_if.should be_nil
          @st.end_if.should be_true
        end
      end
    end

    describe "#if_parameter" do
      context "passes when" do
        it "sees yes" do
          @st.if_parameter("yes").should be_true
          @st.click("About this site").should be_true
          @st.end_if.should be_true
        end

        it "sees true" do
          @st.if_parameter("true").should be_true
          @st.click("About this site").should be_true
          @st.end_if.should be_true
        end

        it "sees YES" do
          @st.if_parameter("YES").should be_true
          @st.click("About this site").should be_true
          @st.end_if.should be_true
        end

        it "sees TRUE" do
          @st.if_parameter("TRUE").should be_true
          @st.click("About this site").should be_true
          @st.end_if.should be_true
        end

        it "is inside a passed block" do
          @st.if_i_see("About this site").should be_true
          @st.click("About this site").should be_true
          @st.page_loads_in_seconds_or_less(10).should be_true
          @st.if_parameter("True").should be_true
          @st.see("is really cool.").should be_true
          @st.end_if.should be_true
          @st.end_if.should be_true
        end
      end

      context "skips when" do
        it "sees something other than yes or true" do
          @st.if_parameter("Bogus").should be_nil
          @st.click("Bogus link").should be_nil
          @st.end_if.should be_true
        end

        it "is inside a skipped block" do
          @st.if_parameter("Bogus link").should be_nil
          @st.click("Bogus link").should be_nil
          @st.if_parameter("TRUE").should be_nil
          @st.click("About this site").should be_nil
          @st.end_if.should be_nil
          @st.end_if.should be_true
        end
      end
    end

    # TODO: if_is
    describe "#if_is" do
      context "passes when" do
        it "sees the same string" do
          @st.if_is("yes", 'yes').should be_true
          @st.click("About this site").should be_true
          @st.end_if.should be_true
        end

        it "sees a matching empty string" do
          @st.if_is("",'').should be_true
          @st.click("About this site").should be_true
          @st.end_if.should be_true
        end

        it "is inside a passed block" do
          @st.if_i_see("About this site").should be_true
          @st.click("About this site").should be_true
          @st.page_loads_in_seconds_or_less(10).should be_true
          @st.if_is("True", "True").should be_true
          @st.see("is really cool.").should be_true
          @st.end_if.should be_true
          @st.end_if.should be_true
        end
      end

      context "skips when" do
        it "sees different strings" do
          @st.if_is("Ken", "Bogus").should be_nil
          @st.click("Bogus link").should be_nil
          @st.end_if.should be_true
        end

        it "is inside a skipped block" do
          @st.if_is("Ken", "Bogus").should be_nil
          @st.click("Bogus link").should be_nil
          @st.if_is("True", "True").should be_nil
          @st.click("About this site").should be_nil
          @st.end_if.should be_nil
          @st.end_if.should be_true
        end
      end
    end

    describe "#otherwise" do
      context "skips when" do
        it "its if was true" do
          @st.if_i_see("About this site").should be_true
          @st.click("About this site").should be_true
          @st.otherwise.should be_nil
          @st.click("Bogus link").should be_nil
          @st.end_if.should be_true
        end
      end
      context "passes when" do
        it "its if was false" do
          @st.if_i_see("Bogus link").should be_nil
          @st.click("Bogus link").should be_nil
          @st.otherwise.should be_true
          @st.click("About this site").should be_true
          @st.end_if.should be_true
        end
      end

      context "fails when" do
        it "does not have a matching if" do
          @st.otherwise.should be_false
        end
      end
    end

    describe "#end_if" do
      context "fails when" do
        it "does not have a matching if" do
          @st.end_if.should be_false
        end
      end
    end
  end # conditionals


  context "buttons" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    describe "#click_button" do
      context "passes when" do
        it "button exists and is enabled" do
          @st.click_button("Submit person form").should be_true
        end

        it "button exists within scope" do
          @st.click_button("Submit person form", :within => "person_form").should be_true
        end

        it "button exists in table row" do
          # TODO
        end
      end

      context "fails when" do
        it "button does not exist" do
          @st.click_button("No such button").should be_false
        end

        it "button exists, but not within scope" do
          @st.click_button("Submit person form", :within => "spouse_form").should be_false
        end

        it "button exists, but not in table row" do
          # TODO
        end

        it "button exists, but is read-only" do
          @st.visit("/readonly_form").should be_true
          @st.click_button("Submit person form").should be_false
        end
      end
    end


    describe "#button_exists" do
      context "passes when" do
        context "button with text" do
          it "exists" do
            @st.button_exists("Submit person form").should be_true
            @st.button_exists("Save preferences").should be_true
          end

          it "exists within scope" do
            @st.button_exists("Submit person form", :within => "person_form").should be_true
            @st.button_exists("Submit spouse form", :within => "spouse_form").should be_true
          end

          it "exists in table row" do
            # TODO
          end
        end
      end

      context "fails when" do
        it "no such button exists" do
          @st.button_exists("Apple").should be_false
          @st.button_exists("Big Red").should be_false
        end

        it "button exists, but not within scope" do
          @st.button_exists("Submit spouse form", :within => "person_form").should be_false
          @st.button_exists("Submit person form", :within => "spouse_form").should be_false
        end

        it "button exists, but not in table row" do
          # TODO
        end
      end
    end
  end # buttons


  context "fields" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    describe "#type_into_field" do
      context "passes when" do
        context "text field with label" do
          it "exists" do
            @st.type_into_field("Eric", "First name").should be_true
            @st.fill_in_with("Last name", "Pierce").should be_true
          end
          it "exists within scope" do
            @st.type_into_field("Eric", "First name", :within => 'person_form').should be_true
            @st.type_into_field("Andrea", "First name", :within => 'spouse_form').should be_true
          end
        end

        context "text field with id" do
          it "exists" do
            @st.type_into_field("Eric", "first_name").should be_true
            @st.fill_in_with("last_name", "Pierce").should be_true
          end
        end

        context "textarea with label" do
          it "exists" do
            @st.type_into_field("Blah blah blah", "Life story").should be_true
            @st.fill_in_with("Life story", "Jibber jabber").should be_true
          end
        end

        context "textarea with id" do
          it "exists" do
            @st.type_into_field("Blah blah blah", "biography").should be_true
            @st.fill_in_with("biography", "Jibber jabber").should be_true
          end
        end
      end

      context "fails when" do
        it "no field with the given label or id exists" do
          @st.type_into_field("Matthew", "Middle name").should be_false
          @st.fill_in_with("middle_name", "Matthew").should be_false
        end

        it "field exists, but not within scope" do
          @st.type_into_field("Long story", "Life story",
                              :within => 'spouse_form').should be_false
        end

        it "field exists, but is read-only" do
          @st.visit("/readonly_form").should be_true
          @st.type_into_field("Eric", "First name").should be_false
        end
      end
    end

    describe "#field_contains" do
      context "passes when" do
        context "text field with label" do
          it "equals the text" do
            @st.fill_in_with("First name", "Marcus")
            @st.field_contains("First name", "Marcus").should be_true
          end

          it "contains the text" do
            @st.fill_in_with("First name", "Marcus")
            @st.field_contains("First name", "Marc").should be_true
          end
        end

        context "textarea with label" do
          it "contains the text" do
            @st.fill_in_with("Life story", "Blah dee blah")
            @st.field_contains("Life story", "blah").should be_true
          end
        end
      end

      context "fails when" do
        context "text field with label" do
          it "does not exist" do
            @st.field_contains("Third name", "Smith").should be_false
          end

          it "does not contain the text" do
            @st.fill_in_with("First name", "Marcus")
            @st.field_contains("First name", "Eric").should be_false
          end
        end

        context "textarea with label" do
          it "does not contain the text" do
            @st.fill_in_with("Life story", "Blah dee blah")
            @st.field_contains("Life story", "spam").should be_false
          end
        end
      end
    end

    describe "#field_equals" do
      context "passes when" do
        context "text field with label" do
          it "equals the text" do
            @st.fill_in_with("First name", "Ken")
            @st.field_equals("First name", "Ken").should be_true
          end

          it "equals the text, and is within scope" do
            @st.fill_in_with("First name", "Eric", :within => "person_form")
            @st.field_equals("First name", "Eric", :within => "person_form")
          end
        end

        context "textarea with label" do
          it "equals the text" do
            @st.fill_in_with("Life story", "Blah dee blah")
            @st.field_equals("Life story", "Blah dee blah").should be_true
          end

          it "equals the text, and is within scope" do
            @st.fill_in_with("Life story", "Blah dee blah",
                             :within => "person_form")
            @st.field_equals("Life story", "Blah dee blah",
                             :within => "person_form").should be_true
          end

          it "equals the text, and is in table row" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "text field with label" do
          it "does not exactly equal the text" do
            @st.fill_in_with("First name", "Marcus")
            @st.field_equals("First name", "Marc").should be_false
          end
        end

        context "textarea with label" do
          it "does not exist" do
            @st.field_equals("Third name", "Smith").should be_false
          end

          it "does not exactly equal the text" do
            @st.fill_in_with("Life story", "Blah dee blah")
            @st.field_equals("Life story", "Blah dee").should be_false
          end

          it "exactly equals the text, but is not within scope" do
            @st.fill_in_with("First name", "Eric", :within => "person_form")
            @st.field_equals("First name", "Eric", :within => "spouse_form").should be_false
          end

          it "exactly equals the text, but is not in table row" do
            # TODO
          end
        end
      end
    end
  end # fields


  context "checkboxes" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    describe "#enable_checkbox" do
      context "passes when" do
        context "checkbox with label" do
          it "exists" do
            @st.enable_checkbox("I like cheese").should be_true
            @st.enable_checkbox("I like salami").should be_true
          end

          it "exists and is already checked" do
            @st.enable_checkbox("I like cheese")
            @st.enable_checkbox("I like cheese").should be_true
          end

          it "exists within scope" do
            @st.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
            @st.enable_checkbox("I like salami", :within => "salami_checkbox").should be_true
          end

          it "exists in table row" do
            @st.visit("/table")
            @st.enable_checkbox("Like", :in_row => "Marcus").should be_true
          end
        end

        context "checkbox with id=" do
          it "exists" do
            @st.enable_checkbox("id=like_cheese").should be_true
          end
        end

        context "checkbox with xpath=" do
          it "exists" do
            @st.enable_checkbox("xpath=//input[@id='like_cheese']").should be_true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            @st.enable_checkbox("I dislike bacon").should be_false
            @st.enable_checkbox("I like broccoli").should be_false
          end

          it "exists, but not within scope" do
            @st.enable_checkbox("I like cheese", :within => "salami_checkbox").should be_false
            @st.enable_checkbox("I like salami", :within => "cheese_checkbox").should be_false
          end

          it "exists, but not in table row" do
            @st.visit("/table")
            @st.enable_checkbox("Like", :in_row => "Eric").should be_false
          end

          it "exists, but is read-only" do
            @st.visit("/readonly_form").should be_true
            @st.enable_checkbox("I like salami").should be_false
          end
        end
      end
    end

    describe "#disable_checkbox" do
      context "passes when" do
        context "checkbox with label" do
          it "exists" do
            @st.disable_checkbox("I like cheese").should be_true
            @st.disable_checkbox("I like salami").should be_true
          end

          it "exists and is already unchecked" do
            @st.disable_checkbox("I like cheese")
            @st.disable_checkbox("I like cheese").should be_true
          end

          it "exists within scope" do
            @st.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
            @st.disable_checkbox("I like salami", :within => "preferences_form").should be_true
          end

          it "exists in table row" do
            @st.visit("/table")
            @st.disable_checkbox("Like", :in_row => "Marcus").should be_true
          end
        end

        context "checkbox with id=" do
          it "exists" do
            @st.disable_checkbox("id=like_cheese").should be_true
          end
        end

        context "checkbox with xpath=" do
          it "exists" do
            @st.disable_checkbox("xpath=//input[@id='like_cheese']").should be_true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            @st.disable_checkbox("I dislike bacon").should be_false
            @st.disable_checkbox("I like broccoli").should be_false
          end

          it "exists, but not within scope" do
            @st.disable_checkbox("I like cheese", :within => "salami_checkbox").should be_false
            @st.disable_checkbox("I like salami", :within => "cheese_checkbox").should be_false
          end

          it "exists, but not in table row" do
            @st.visit("/table")
            @st.disable_checkbox("Like", :in_row => "Eric").should be_false
          end

          it "exists, but is read-only" do
            @st.visit("/readonly_form").should be_true
            @st.disable_checkbox("I like cheese").should be_false
          end
        end
      end
    end

    describe "#checkbox_is_enabled" do
      context "passes when" do
        context "checkbox with label" do
          it "exists and is checked" do
            @st.enable_checkbox("I like cheese").should be_true
            @st.checkbox_is_enabled("I like cheese").should be_true
          end

          it "exists within scope and is checked" do
            @st.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
            @st.checkbox_is_enabled("I like cheese", :within => "cheese_checkbox").should be_true
          end

          it "exists in table row and is checked" do
            @st.visit("/table")
            @st.enable_checkbox("Like", :in_row => "Ken").should be_true
            @st.checkbox_is_enabled("Like", :in_row => "Ken").should be_true
          end

          it "exists and is checked, but read-only" do
            @st.visit("/readonly_form").should be_true
            @st.checkbox_is_enabled("I like cheese").should be_true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            @st.checkbox_is_enabled("I dislike bacon").should be_false
          end

          it "exists but is unchecked" do
            @st.disable_checkbox("I like cheese").should be_true
            @st.checkbox_is_enabled("I like cheese").should be_false
          end

          it "exists and is checked, but not within scope" do
            @st.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
            @st.checkbox_is_enabled("I like cheese", :within => "salami_checkbox").should be_false
          end

          it "exists and is checked, but not in table row" do
            @st.visit("/table")
            @st.enable_checkbox("Like", :in_row => "Marcus").should be_true
            @st.checkbox_is_enabled("Like", :in_row => "Eric").should be_false
          end
        end
      end
    end

    describe "#checkbox_is_disabled" do
      context "passes when" do
        context "checkbox with label" do
          it "exists and is unchecked" do
            @st.disable_checkbox("I like cheese").should be_true
            @st.checkbox_is_disabled("I like cheese").should be_true
          end

          it "exists within scope and is unchecked" do
            @st.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
            @st.checkbox_is_disabled("I like cheese", :within => "cheese_checkbox").should be_true
          end

          it "exists in table row and is unchecked" do
            @st.visit("/table")
            @st.disable_checkbox("Like", :in_row => "Ken").should be_true
            @st.checkbox_is_disabled("Like", :in_row => "Ken").should be_true
          end

          it "exists and is unchecked, but read-only" do
            @st.visit("/readonly_form").should be_true
            @st.checkbox_is_disabled("I like salami").should be_true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            @st.checkbox_is_disabled("I dislike bacon").should be_false
          end

          it "exists but is checked" do
            @st.enable_checkbox("I like cheese").should be_true
            @st.checkbox_is_disabled("I like cheese").should be_false
          end

          it "exists and is unchecked, but not within scope" do
            @st.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
            @st.checkbox_is_disabled("I like cheese", :within => "salami_checkbox").should be_false
          end

          it "exists and is unchecked, but not in table row" do
            @st.visit("/table")
            @st.disable_checkbox("Like", :in_row => "Marcus").should be_true
            @st.checkbox_is_disabled("Like", :in_row => "Eric").should be_false
          end
        end
      end
    end
  end # checkboxes


  context "radiobuttons" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    context "#select_radio" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists" do
            @st.select_radio("Briefs").should be_true
          end

          it "exists within scope" do
            @st.select_radio("Briefs", :within => "clothing").should be_true
          end

          it "exists in table row" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            @st.select_radio("Naked").should be_false
          end

          it "exists, but not within scope" do
            @st.select_radio("Briefs", :within => "food").should be_false
          end

          it "exists, but is read-only" do
            @st.visit("/readonly_form").should be_true
            @st.select_radio("Boxers").should be_false
          end

          it "exists, but not in table row" do
            # TODO
          end
        end
      end
    end

    context "#radio_is_enabled" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists, and is enabled" do
            @st.select_radio("Briefs")
            @st.radio_is_enabled("Briefs").should be_true
          end

          it "exists within scope, and is enabled" do
            @st.select_radio("Briefs", :within => "clothing")
            @st.radio_is_enabled("Briefs", :within => "clothing").should be_true
          end

          it "exists in table row, and is enabled" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            @st.radio_is_enabled("Naked").should be_false
          end

          it "exists, but is not enabled" do
            @st.select_radio("Briefs")
            @st.radio_is_enabled("Boxers").should be_false
          end

          it "exists and is enabled, but not within scope" do
            @st.select_radio("Briefs", :within => "clothing")
            @st.radio_is_enabled("Briefs", :within => "food").should be_false
          end
        end
      end
    end
  end # radiobuttons


  context "dropdowns" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    context "#select_from_dropdown" do
      context "passes when" do
        it "option exists in the dropdown" do
          @st.select_from_dropdown("Tall", "Height").should be_true
          @st.select_from_dropdown("Medium", "Weight").should be_true
        end

        it "option exists in the dropdown within scope" do
          @st.select_from_dropdown("Tall", "Height", :within => "spouse_form").should be_true
        end

        it "option exists in the dropdown in table row" do
          @st.visit("/table")
          @st.select_from_dropdown("Male", "Gender", :in_row => "Eric").should be_true
        end
      end

      context "fails when" do
        it "no such dropdown exists" do
          @st.select_from_dropdown("Over easy", "Eggs").should be_false
        end

        it "dropdown exists, but the option doesn't" do
          @st.select_from_dropdown("Giant", "Height").should be_false
          @st.select_from_dropdown("Obese", "Weight").should be_false
        end

        it "dropdown exists, but is read-only" do
          @st.visit("/readonly_form").should be_true
          @st.select_from_dropdown("Tall", "Height").should be_false
        end

        it "dropdown exists, but not within scope" do
          @st.select_from_dropdown("Medium", "Weight", :within => "spouse_form").should be_false
        end

        it "dropdown exists, but not in table row" do
          @st.visit("/table")
          @st.select_from_dropdown("Female", "Gender", :in_row => "First name").should be_false
        end
      end
    end

    context "#dropdown_includes" do
      context "passes when" do
        it "option exists in the dropdown" do
          @st.dropdown_includes("Height", "Tall").should be_true
          @st.dropdown_includes("Weight", "Medium").should be_true
        end

        it "option exists in a read-only dropdown" do
          @st.visit("/readonly_form").should be_true
          @st.dropdown_includes("Height", "Tall").should be_true
        end
      end

      context "fails when" do
        it "dropdown exists, but the option doesn't" do
          @st.dropdown_includes("Height", "Giant").should be_false
          @st.dropdown_includes("Weight", "Obese").should be_false
        end

        it "no such dropdown exists" do
          @st.dropdown_includes("Eggs", "Over easy").should be_false
        end
      end
    end

    context "#dropdown_equals" do
      context "passes when" do
        it "option is selected in the dropdown" do
          ["Short", "Average", "Tall"].each do |height|
            @st.select_from_dropdown(height, "Height")
            @st.dropdown_equals("Height", height).should be_true
          end
        end

        it "option is selected in a read-only dropdown" do
          @st.visit("/readonly_form").should be_true
          @st.dropdown_equals("Height", "Average").should be_true
        end

        it "option is selected in the dropdown, within scope" do
          ["Short", "Average", "Tall"].each do |height|
            @st.select_from_dropdown(height, "Height", :within => "spouse_form")
            @st.dropdown_equals("Height", height, :within => "spouse_form").should be_true
          end
        end

        it "option is selected in the dropdown, in table row" do
          @st.visit("/table")
          ["Male", "Female"].each do |gender|
            @st.select_from_dropdown(gender, "Gender", :in_row => "Eric")
            @st.dropdown_equals("Gender", gender, :in_row => "Eric")
          end
        end
      end

      context "fails when" do
        it "no such dropdown exists" do
          @st.dropdown_equals("Eggs", "Over easy").should be_false
        end

        it "dropdown exists, but the option is not selected" do
          @st.select_from_dropdown("Short", "Height")
          @st.dropdown_equals("Height", "Average").should be_false
          @st.dropdown_equals("Height", "Tall").should be_false

          @st.select_from_dropdown("Average", "Height")
          @st.dropdown_equals("Height", "Short").should be_false
          @st.dropdown_equals("Height", "Tall").should be_false

          @st.select_from_dropdown("Tall", "Height")
          @st.dropdown_equals("Height", "Short").should be_false
          @st.dropdown_equals("Height", "Average").should be_false
        end

        it "dropdown exists, and option is selected, but not within scope" do
          @st.select_from_dropdown("Tall", "Height", :within => "person_form")
          @st.select_from_dropdown("Short", "Height", :within => "spouse_form")
          @st.dropdown_equals("Height", "Tall", :within => "spouse_form").should be_false
        end

        it "dropdown exists, and option is selected, but not in table row" do
          @st.visit("/table")
          @st.select_from_dropdown("Female", "Gender", :in_row => "Eric")
          @st.select_from_dropdown("Male", "Gender", :in_row => "Marcus")
          @st.dropdown_equals("Gender", "Female", :in_row => "Marcus").should be_false
        end
      end
    end
  end # dropdowns

  # The same field operations, but with the generic set_field function...
  context "generic_fields" do
    # TODO: Remove entries that don't use "set_field" in the next 600 or so lines.
    describe "#set_field" do
      context "fields" do
        before(:each) do
          @st.visit("/form").should be_true
        end

        context "#set_field with #type_into_field" do
          context "passes when" do
            context "text field with label" do
              it "exists" do
                @st.set_field("First name", "Eric").should be_true
                @st.set_field("Last name", "Pierce").should be_true
              end
              it "exists within scope" do
                @st.set_field("First name", "Eric", :within => 'person_form').should be_true
                @st.set_field("First name", "Andrea", :within => 'spouse_form').should be_true
              end
            end

            context "text field with id" do
              it "exists" do
                @st.set_field("first_name", "Eric").should be_true
                @st.set_field("last_name", "Pierce").should be_true
              end
            end

            context "textarea with label" do
              it "exists" do
                @st.set_field("Life story", "Blah blah blah").should be_true
                @st.set_field("Life story", "Jibber jabber").should be_true
              end
            end

            context "textarea with id" do
              it "exists" do
                @st.set_field("biography", "Blah blah blah").should be_true
                @st.set_field("biography", "Jibber jabber").should be_true
              end
            end
          end

          context "fails when" do
            it "no field with the given label or id exists" do
              @st.set_field("Middle name", "Matthew").should be_false
              @st.set_field("middle_name", "Matthew").should be_false
            end

            it "field exists, but not within scope" do
              @st.set_field("Life story", "Long story",
                            :within => 'spouse_form').should be_false
            end

            it "field exists, but is read-only" do
              @st.visit("/readonly_form").should be_true
              @st.set_field("First name", "Eric").should be_false
            end
          end
        end

        context "#set_field with #field_contains" do
          context "passes when" do
            context "text field with label" do
              it "equals the text" do
                @st.set_field("First name", "Marcus")
                @st.field_contains("First name", "Marcus").should be_true
              end

              it "contains the text" do
                @st.set_field("First name", "Marcus")
                @st.field_contains("First name", "Marc").should be_true
              end
            end

            context "textarea with label" do
              it "contains the text" do
                @st.set_field("Life story", "Blah dee blah")
                @st.field_contains("Life story", "blah").should be_true
              end
            end
          end

          context "fails when" do
            context "text field with label" do
              it "does not contain the text" do
                @st.set_field("First name", "Marcus")
                @st.field_contains("First name", "Eric").should be_false
              end
            end

            context "textarea with label" do
              it "does not contain the text" do
                @st.set_field("Life story", "Blah dee blah")
                @st.field_contains("Life story", "spam").should be_false
              end
            end
          end
        end

        context "#set_field with #generic_field_equals" do
          context "passes when" do
            context "text field with label" do
              it "equals the text" do
                @st.set_field("First name", "Ken")
                @st.generic_field_equals("First name", "Ken").should be_true
              end

              it "equals the text, and is within scope" do
                @st.set_field("First name", "Eric", :within => "person_form")
                @st.generic_field_equals("First name", "Eric", :within => "person_form")
              end
            end

            context "textarea with label" do
              it "equals the text" do
                @st.set_field("Life story", "Blah dee blah")
                @st.generic_field_equals("Life story", "Blah dee blah").should be_true
              end

              it "equals the text, and is within scope" do
                @st.set_field("Life story", "Blah dee blah",
                              :within => "person_form")
                @st.generic_field_equals("Life story", "Blah dee blah",
                                 :within => "person_form").should be_true
              end

              it "equals the text, and is in table row" do
                # TODO
              end
            end
          end

          context "fails when" do
            context "text field with label" do
              it "does not exactly equal the text" do
                @st.set_field("First name", "Marcus")
                @st.generic_field_equals("First name", "Marc").should be_false
              end
            end

            context "textarea with label" do
              it "does not exist" do
                @st.generic_field_equals("Third name", "Smith").should be_false
              end

              it "does not exactly equal the text" do
                @st.set_field("Life story", "Blah dee blah")
                @st.generic_field_equals("Life story", "Blah dee").should be_false
              end

              it "exactly equals the text, but is not within scope" do
                @st.set_field("First name", "Eric", :within => "person_form")
                @st.generic_field_equals("First name", "Eric", :within => "spouse_form").should be_false
              end

              it "exactly equals the text, but is not in table row" do
                # TODO
              end
            end
          end
        end
      end # fields


      context "checkboxes" do
        before(:each) do
          @st.visit("/form").should be_true
        end

        context "#set_field with #enable_checkbox" do
          context "passes when" do
            context "checkbox with label" do
              it "exists" do
                @st.set_field("I like cheese", "on").should be_true
                @st.set_field("I like salami", "on").should be_true
                @st.generic_field_equals("I like cheese", "on").should be_true
                @st.generic_field_equals("I like salami", "on").should be_true
              end

              it "exists and is already checked" do
                @st.set_field("I like cheese", "on").should be_true
                @st.set_field("I like cheese", "on").should be_true
                @st.generic_field_equals("I like cheese", "on").should be_true
              end

              it "exists within scope" do
                @st.set_field("I like cheese", "on", :within => "cheese_checkbox").should be_true
                @st.set_field("I like salami", "on", :within => "salami_checkbox").should be_true
                @st.generic_field_equals("I like cheese", "on", :within => "cheese_checkbox").should be_true
                @st.generic_field_equals("I like salami", "on", :within => "salami_checkbox").should be_true
              end

              it "exists in table row" do
                @st.visit("/table")
                @st.set_field("Like", "on", :in_row => "Marcus").should be_true
                @st.generic_field_equals("Like", "on", :in_row => "Marcus").should be_true
              end
            end

            context "checkbox with id=" do
              it "exists" do
                @st.set_field("id=like_cheese", "on").should be_true
                @st.generic_field_equals("id=like_cheese", "on").should be_true
              end
            end

            context "checkbox with xpath=" do
              it "exists" do
                @st.set_field("xpath=//input[@id='like_cheese']", "on").should be_true
                @st.generic_field_equals("xpath=//input[@id='like_cheese']", "on").should be_true
              end
            end
          end

          context "fails when" do
            context "checkbox with label" do
              it "does not exist" do
                @st.set_field("I dislike bacon", "on").should be_false
                @st.set_field("I like broccoli", "on").should be_false
              end

              it "exists, but not within scope" do
                @st.set_field("I like cheese", "on", :within => "salami_checkbox").should be_false
                @st.set_field("I like salami", "on", :within => "cheese_checkbox").should be_false
              end

              it "exists, but not in table row" do
                @st.visit("/table")
                @st.set_field("Like", "on", :in_row => "Eric").should be_false
              end

              it "exists, but is read-only" do
                @st.visit("/readonly_form").should be_true
                @st.set_field("I like salami", "on").should be_false
              end
            end
          end
        end

        context "#set_field with #disable_checkbox" do
          context "passes when" do
            context "checkbox with label" do
              it "exists" do
                @st.set_field("I like cheese", "off").should be_true
                @st.set_field("I like salami", "off").should be_true
                @st.generic_field_equals("I like cheese", "off").should be_true
                @st.generic_field_equals("I like salami", "off").should be_true
              end

              it "exists and is already unchecked" do
                @st.set_field("I like cheese", "off").should be_true
                @st.set_field("I like cheese", "off").should be_true
                @st.generic_field_equals("I like cheese", "off").should be_true
              end

              it "exists within scope" do
                @st.set_field("I like cheese", "off", :within => "cheese_checkbox").should be_true
                @st.set_field("I like salami", "off", :within => "preferences_form").should be_true
                @st.generic_field_equals("I like cheese", "off", :within => "cheese_checkbox").should be_true
                @st.generic_field_equals("I like salami", "off", :within => "preferences_form").should be_true
              end

              it "exists in table row" do
                @st.visit("/table")
                @st.set_field("Like", "off", :in_row => "Marcus").should be_true
                @st.generic_field_equals("Like", "off", :in_row => "Marcus").should be_true
              end
            end

            context "checkbox with id=" do
              it "exists" do
                @st.set_field("id=like_cheese", "off").should be_true
                @st.generic_field_equals("id=like_cheese", "off").should be_true
              end
            end

            context "checkbox with xpath=" do
              it "exists" do
                @st.set_field("xpath=//input[@id='like_cheese']", "off").should be_true
                @st.generic_field_equals("xpath=//input[@id='like_cheese']", "off").should be_true
              end
            end
          end

          context "fails when" do
            context "checkbox with label" do
              it "does not exist" do
                @st.set_field("I dislike bacon", "off").should be_false
                @st.set_field("I like broccoli", "off").should be_false
              end

              it "exists, but not within scope" do
                @st.set_field("I like cheese", "off", :within => "salami_checkbox").should be_false
                @st.set_field("I like salami", "off", :within => "cheese_checkbox").should be_false
              end

              it "exists, but not in table row" do
                @st.visit("/table")
                @st.set_field("Like", "off", :in_row => "Eric").should be_false
              end

              it "exists, but is read-only" do
                @st.visit("/readonly_form").should be_true
                @st.set_field("I like cheese", "off").should be_false
              end
            end
          end
        end

        context "#set_field with #checkbox_is_enabled" do
          context "passes when" do
            context "checkbox with label" do
              it "exists and is checked" do
                @st.set_field("I like cheese", "on").should be_true
                @st.checkbox_is_enabled("I like cheese").should be_true
              end

              it "exists within scope and is checked" do
                @st.set_field("I like cheese", "on", :within => "cheese_checkbox").should be_true
                @st.checkbox_is_enabled("I like cheese", :within => "cheese_checkbox").should be_true
              end

              it "exists in table row and is checked" do
                @st.visit("/table")
                @st.set_field("Like", "on", :in_row => "Ken").should be_true
                @st.checkbox_is_enabled("Like", :in_row => "Ken").should be_true
              end

              it "exists and is checked, but read-only" do
                @st.visit("/readonly_form").should be_true
                @st.checkbox_is_enabled("I like cheese").should be_true
              end
            end
          end

          context "fails when" do
            context "checkbox with label" do
              it "does not exist" do
                @st.checkbox_is_enabled("I dislike bacon").should be_false
              end

              it "exists but is unchecked" do
                @st.set_field("I like cheese", "off").should be_true
                @st.checkbox_is_enabled("I like cheese").should be_false
              end

              it "exists and is checked, but not within scope" do
                @st.set_field("I like cheese", "on", :within => "cheese_checkbox").should be_true
                @st.checkbox_is_enabled("I like cheese", :within => "salami_checkbox").should be_false
              end

              it "exists and is checked, but not in table row" do
                @st.visit("/table")
                @st.set_field("Like", "on", :in_row => "Marcus").should be_true
                @st.checkbox_is_enabled("Like", :in_row => "Eric").should be_false
              end
            end
          end
        end

        context "#set_field with #checkbox_is_disabled" do
          context "passes when" do
            context "checkbox with label" do
              it "exists and is unchecked" do
                @st.set_field("I like cheese", "off").should be_true
                @st.checkbox_is_disabled("I like cheese").should be_true
              end

              it "exists within scope and is unchecked" do
                @st.set_field("I like cheese", "off", :within => "cheese_checkbox").should be_true
                @st.checkbox_is_disabled("I like cheese", :within => "cheese_checkbox").should be_true
              end

              it "exists in table row and is unchecked" do
                @st.visit("/table")
                @st.set_field("Like", "off", :in_row => "Ken").should be_true
                @st.checkbox_is_disabled("Like", :in_row => "Ken").should be_true
              end

              it "exists and is unchecked, but read-only" do
                @st.visit("/readonly_form").should be_true
                @st.checkbox_is_disabled("I like salami").should be_true
              end
            end
          end

          context "fails when" do
            context "checkbox with label" do
              it "does not exist" do
                @st.checkbox_is_disabled("I dislike bacon").should be_false
              end

              it "exists but is checked" do
                @st.set_field("I like cheese", "on").should be_true
                @st.checkbox_is_disabled("I like cheese").should be_false
              end

              it "exists and is unchecked, but not within scope" do
                @st.set_field("I like cheese", "off", :within => "cheese_checkbox").should be_true
                @st.checkbox_is_disabled("I like cheese", :within => "salami_checkbox").should be_false
              end

              it "exists and is unchecked, but not in table row" do
                @st.visit("/table")
                @st.set_field("Like", "off", :in_row => "Marcus").should be_true
                @st.checkbox_is_disabled("Like", :in_row => "Eric").should be_false
              end
            end
          end
        end
      end # checkboxes


      context "radiobuttons" do
        before(:each) do
          @st.visit("/form").should be_true
        end

        context "#set_field with #select_radio" do
          context "passes when" do
            context "radiobutton with label" do
              it "exists" do
                @st.set_field("Briefs").should be_true
              end

              it "exists within scope" do
                @st.set_field("Briefs", "", :within => "clothing").should be_true
              end

              it "exists in table row" do
                # TODO
              end
            end
          end

          context "fails when" do
            context "radiobutton with label" do
              it "does not exist" do
                @st.set_field("Naked", "").should be_false
              end

              it "exists, but not within scope" do
                @st.set_field("Briefs", "", :within => "food").should be_false
              end

              it "exists, but is read-only" do
                @st.visit("/readonly_form").should be_true
                @st.set_field("Boxers", "").should be_false
              end

              it "exists, but not in table row" do
                # TODO
              end
            end
          end
        end

        context "#set_field with #radio_is_enabled" do
          context "passes when" do
            context "radiobutton with label" do
              it "exists, and is enabled" do
                @st.set_field("Briefs")
                @st.radio_is_enabled("Briefs").should be_true
              end

              it "exists within scope, and is enabled" do
                @st.set_field("Briefs", "", :within => "clothing")
                @st.radio_is_enabled("Briefs", :within => "clothing").should be_true
              end

              it "exists in table row, and is enabled" do
                # TODO
              end
            end
          end

          context "fails when" do
            context "radiobutton with label" do
              it "does not exist" do
                @st.radio_is_enabled("Naked").should be_false
              end

              it "exists, but is not enabled" do
                @st.set_field("Briefs", "")
                @st.radio_is_enabled("Boxers").should be_false
              end

              it "exists and is enabled, but not within scope" do
                @st.set_field("Briefs", "", :within => "clothing")
                @st.radio_is_enabled("Briefs", :within => "food").should be_false
              end
            end
          end

        context "#set_field with #generic_field_equals for #radio_is_enabled" do
          context "passes when" do
            context "radiobutton with label" do
              it "exists, and is enabled" do
                @st.set_field("Briefs")
                @st.generic_field_equals("Briefs", "on").should be_true
              end

              it "exists within scope, and is enabled" do
                @st.set_field("Briefs", "", :within => "clothing")
                @st.generic_field_equals("Briefs", "on", :within => "clothing").should be_true
              end

              it "exists in table row, and is enabled" do
                # TODO
              end
            end
          end

          context "fails when" do
            context "radiobutton with label" do
              it "does not exist" do
                @st.generic_field_equals("Naked", "on").should be_false
              end

              it "exists, but is not enabled" do
                @st.set_field("Briefs", "")
                @st.generic_field_equals("Boxers", "on").should be_false
              end

              it "exists and is enabled, but not within scope" do
                @st.set_field("Briefs", "", :within => "clothing")
                @st.generic_field_equals("Briefs", "on", :within => "food").should be_false
              end
            end
          end
        end
      end # radiobuttons


      context "dropdowns" do
        before(:each) do
          @st.visit("/form").should be_true
        end

        context "#set_field with #select_from_dropdown" do
          context "passes when" do
            it "option exists in the dropdown" do
              @st.set_field("Height", "Tall").should be_true
              @st.set_field("Weight", "Medium").should be_true
            end

            it "option exists in the dropdown within scope" do
              @st.set_field("Height", "Tall", :within => "spouse_form").should be_true
            end

            it "option exists in the dropdown in table row" do
              @st.visit("/table")
              @st.set_field("Gender", "Male", :in_row => "Eric").should be_true
            end
          end

          context "fails when" do
            it "no such dropdown exists" do
              @st.set_field("Eggs", "Over easy").should be_false
            end

            it "dropdown exists, but the option doesn't" do
              @st.set_field("Height", "Giant").should be_false
              @st.set_field("Weight", "Obese").should be_false
            end

            it "dropdown exists, but is read-only" do
              @st.visit("/readonly_form").should be_true
              @st.set_field("Height", "Tall").should be_false
            end

            it "dropdown exists, but not within scope" do
              @st.set_field("Weight", "Medium", :within => "spouse_form").should be_false
            end

            it "dropdown exists, but not in table row" do
              @st.visit("/table")
              @st.set_field("Gender", "Female", :in_row => "First name").should be_false
            end
          end
        end

        context "#set_field with #dropdown_includes" do
          context "passes when" do
            it "option exists in the dropdown" do
              @st.dropdown_includes("Height", "Tall").should be_true
              @st.dropdown_includes("Weight", "Medium").should be_true
            end

            it "option exists in a read-only dropdown" do
              @st.visit("/readonly_form").should be_true
              @st.dropdown_includes("Height", "Tall").should be_true
            end
          end

          context "fails when" do
            it "dropdown exists, but the option doesn't" do
              @st.dropdown_includes("Height", "Giant").should be_false
              @st.dropdown_includes("Weight", "Obese").should be_false
            end

            it "no such dropdown exists" do
              @st.dropdown_includes("Eggs", "Over easy").should be_false
            end
          end
        end

        context "#set_field with #dropdown_equals" do
          context "passes when" do
            it "option is selected in the dropdown" do
              ["Short", "Average", "Tall"].each do |height|
                @st.set_field("Height", height)
                @st.dropdown_equals("Height", height).should be_true
              end
            end

            it "option is selected in a read-only dropdown" do
              @st.visit("/readonly_form").should be_true
              @st.dropdown_equals("Height", "Average").should be_true
            end

            it "option is selected in the dropdown, within scope" do
              ["Short", "Average", "Tall"].each do |height|
                @st.set_field("Height", height, :within => "spouse_form")
                @st.dropdown_equals("Height", height, :within => "spouse_form").should be_true
              end
            end

            it "option is selected in the dropdown, in table row" do
              @st.visit("/table")
              ["Male", "Female"].each do |gender|
                @st.set_field("Gender", gender, :in_row => "Eric")
                @st.dropdown_equals("Gender", gender, :in_row => "Eric")
              end
            end
          end

          context "fails when" do
            it "no such dropdown exists" do
              @st.dropdown_equals("Eggs", "Over easy").should be_false
            end

            it "dropdown exists, but the option is not selected" do
              @st.set_field("Height", "Short")
              @st.dropdown_equals("Height", "Average").should be_false
              @st.dropdown_equals("Height", "Tall").should be_false

              @st.set_field("Height", "Average")
              @st.dropdown_equals("Height", "Short").should be_false
              @st.dropdown_equals("Height", "Tall").should be_false

              @st.set_field("Height", "Tall")
              @st.dropdown_equals("Height", "Short").should be_false
              @st.dropdown_equals("Height", "Average").should be_false
            end

            it "dropdown exists, and option is selected, but not within scope" do
              @st.set_field("Height", "Tall", :within => "person_form")
              @st.set_field("Height", "Short", :within => "spouse_form")
              @st.dropdown_equals("Height", "Tall", :within => "spouse_form").should be_false
            end

            it "dropdown exists, and option is selected, but not in table row" do
              @st.visit("/table")
              @st.set_field("Gender", "Female", :in_row => "Eric")
              @st.set_field("Gender", "Male", :in_row => "Marcus")
              @st.dropdown_equals("Gender", "Female", :in_row => "Marcus").should be_false
            end
          end
        end

        context "#set_field with #generic_field_equals for #dropdown_equals" do
          context "passes when" do
            it "option is selected in the dropdown" do
              ["Short", "Average", "Tall"].each do |height|
                @st.set_field("Height", height)
                @st.generic_field_equals("Height", height).should be_true
              end
            end

            it "option is selected in a read-only dropdown" do
              @st.visit("/readonly_form").should be_true
              @st.generic_field_equals("Height", "Average").should be_true
            end

            it "option is selected in the dropdown, within scope" do
              ["Short", "Average", "Tall"].each do |height|
                @st.set_field("Height", height, :within => "spouse_form")
                @st.generic_field_equals("Height", height, :within => "spouse_form").should be_true
              end
            end

            it "option is selected in the dropdown, in table row" do
              @st.visit("/table")
              ["Male", "Female"].each do |gender|
                @st.set_field("Gender", gender, :in_row => "Eric")
                @st.generic_field_equals("Gender", gender, :in_row => "Eric")
              end
            end
          end

          context "fails when" do
            it "no such dropdown exists" do
              @st.generic_field_equals("Eggs", "Over easy").should be_false
            end

            it "dropdown exists, but the option is not selected" do
              @st.set_field("Height", "Short")
              @st.generic_field_equals("Height", "Average").should be_false
              @st.generic_field_equals("Height", "Tall").should be_false

              @st.set_field("Height", "Average")
              @st.generic_field_equals("Height", "Short").should be_false
              @st.generic_field_equals("Height", "Tall").should be_false

              @st.set_field("Height", "Tall")
              @st.generic_field_equals("Height", "Short").should be_false
              @st.generic_field_equals("Height", "Average").should be_false
            end

            it "dropdown exists, and option is selected, but not within scope" do
              @st.set_field("Height", "Tall", :within => "person_form")
              @st.set_field("Height", "Short", :within => "spouse_form")
              @st.generic_field_equals("Height", "Tall", :within => "spouse_form").should be_false
            end

            it "dropdown exists, and option is selected, but not in table row" do
              @st.visit("/table")
              @st.set_field("Gender", "Female", :in_row => "Eric")
              @st.set_field("Gender", "Male", :in_row => "Marcus")
              @st.generic_field_equals("Gender", "Female", :in_row => "Marcus").should be_false
            end
          end
        end
      end # dropdowns
    end # set_field


    # TODO: Add test cases with scopes to the next three functions described.
    describe "#set_field_among" do
      before(:each) do
        @st.visit("/form").should be_true
      end
      context "passes when" do
        context "text field with label" do
          it "equals the page text" do
            @st.set_field_among("First name", "Marcus", "Last name" => "nowhere").should be_true
            @st.field_contains("First name", "Marcus").should be_true
          end

          it "equals the page text and has no ids" do
            @st.set_field_among("First name", "Marcus", "").should be_true
            @st.field_contains("First name", "Marcus").should be_true
          end

          it "equals the hash text" do
            @st.set_field_among("Last name", "Marcus", "Last name" => "First name").should be_true
            @st.field_contains("First name", "Marcus").should be_true
          end

          it "equals the escaped hash text" do
            @st.set_field_among("Last:name", "Marcus", "Last\\;name" => "First name").should be_true
            @st.field_contains("First name", "Marcus").should be_true
          end
        end
      end

      context "fails when" do
        context "text field with label" do
          it "does not exist" do
            @st.set_field_among("Third name", "Smith").should be_false
          end

          it "has a hash value that does not exist" do
            @st.set_field_among("Last name", "Smith", "Last name" => "Third name").should be_false
          end
        end
      end
    end # set_field_among

    describe "#field_equals_among" do
      before(:each) do
        @st.visit("/form").should be_true
      end
      context "passes when" do
        context "text field with label" do
          it "equals the page text" do
            @st.set_field_among("First name", "Marcus", "Last name" => "nowhere").should be_true
            @st.field_equals_among("First name", "Marcus", "Last name" => "nowhere").should be_true
          end

          it "equals the page text and has no ids" do
            @st.set_field_among("First name", "Marcus", "").should be_true
            @st.field_equals_among("First name", "Marcus", "").should be_true
          end

          it "equals the hash text" do
            @st.set_field_among("Last name", "Marcus", "Last name" => "First name").should be_true
            @st.field_equals_among("Last name", "Marcus", "Last name" => "First name").should be_true
          end

          it "equals the escaped hash text" do
            @st.set_field_among("Last:name", "Marcus", "Last\\;name" => "First name").should be_true
            @st.field_equals_among("Last:name", "Marcus", "Last\\;name" => "First name").should be_true
          end
        end
      end

      context "fails when" do
        context "text field with label" do
          it "does not exist" do
            @st.field_equals_among("Third name", "").should be_false
          end

          it "has a hash value that does not exist" do
            @st.field_equals_among("Last name", "", "Last name" => "Third name").should be_false
          end

          it "does not equal the expected text" do
            @st.field_equals_among("Last name", "Marcus", "Last name" => "First name").should be_false
          end
        end
      end
    end # field_equals_among

    describe "#set_fields" do
      before(:each) do
        @st.visit("/form").should be_true
      end
      context "passes when" do
        context "text fields with labels" do
          it "sets one field" do
            @st.set_fields("First name" => "Marcus").should be_true
            @st.field_contains("First name", "Marcus").should be_true
          end

          it "sets zero fields" do
            @st.set_fields("").should be_true
          end

          it "sets several fields" do
            @st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
            @st.field_contains("First name", "Ken").should be_true
            @st.field_contains("Last name", "Brazier").should be_true
            @st.field_contains("Life story", "story: I get testy").should be_true
          end
        end
      end

      context "fails when" do
        context "text fields with labels" do
          it "cant find the first field" do
            @st.set_fields("Faust name" => "Ken", "Last name" => "Brazier").should be_false
          end

          it "cant find the last field" do
            @st.set_fields("First name" => "Ken", "Lost name" => "Brazier").should be_false
          end
        end
      end
    end # set_fields

    describe "#fields_equal" do
      before(:each) do
        @st.visit("/form").should be_true
      end
      context "passes when" do
        context "text fields with labels" do
          it "sets one field" do
            @st.set_fields("First name" => "Marcus").should be_true
            @st.fields_equal("First name" => "Marcus").should be_true
          end

          it "sets zero fields" do
            @st.fields_equal("").should be_true
          end

          it "sets several fields" do
            @st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
            @st.fields_equal("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
          end
        end
      end

      context "fails when" do
        context "text fields with labels" do
          it "cant find the first field" do
            @st.fields_equal("Faust name" => "", "Last name" => "").should be_false
          end

          it "cant find the last field" do
            @st.fields_equal("First name" => "", "Lost name" => "").should be_false
          end

          it "fields are not equal" do
            @st.fields_equal("First name" => "Ken", "Last name" => "Brazier").should be_false
          end
        end
      end
    end # fields_equal


    describe "#set_fields_among" do
      before(:each) do
        @st.visit("/form").should be_true
      end
      context "passes when" do
        context "text fields with labels" do
          it "sets one field" do
            @st.set_fields_among({"First name" => "Marcus"}).should be_true
            @st.field_contains("First name", "Marcus").should be_true
          end

          it "sets one field with string ids" do
            @st.set_fields_among({"First name" => "Marcus"}, "").should be_true
            @st.field_contains("First name", "Marcus").should be_true
          end

          it "does nothing, but has ids" do
            @st.set_fields_among("", {"First name" => "Marcus"}).should be_true
          end

          it "sets several fields" do
            @st.set_fields_among({"First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot."})
            @st.field_contains("First name", "Ken").should be_true
            @st.field_contains("Last name", "Brazier").should be_true
            @st.field_contains("Life story", "story: I get testy").should be_true
          end
        end
        context "text fields with labels in a hash" do
          it "sets one field from a hash" do
            @st.set_fields_among({"Faust name" => "Marcus"}, {"Faust Name" => "First name", "LOST name" => "Last name"}).should be_true
            @st.field_contains("First name", "Marcus").should be_true
          end

          it "sets many fields, some from a hash" do
            @st.set_fields_among({"Faust\\;name" => "Ken", :Lost => "Brazier", "Life story" => "I get testy a lot."},
                                 {"Faust\\;Name" => "First name", :LOST => "Last name"}).should be_true
            @st.field_contains("First name", "Ken").should be_true
            @st.field_contains("Last name", "Brazier").should be_true
            @st.field_contains("Life story", "testy").should be_true
          end
        end
      end

      context "fails when" do
        context "text fields with labels" do
          it "cant find the first field" do
            @st.set_fields_among({"Faust name" => "Ken", "Last name" => "Brazier"}).should be_false
          end

          it "cant find the last field" do
            @st.set_fields_among({"First name" => "Ken", "Lost name" => "Brazier"}).should be_false
          end
        end
        context "text fields with labels in a hash" do
          it "cant find the first field" do
            @st.set_fields_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                                 {"Faust Name" => "Lost name", "Lost name" => "Last name"}).should be_false
          end

          it "cant find the last field" do
            @st.set_fields_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                                 {"Faust Name" => "First name", "Lost name" => "Faust name"}).should be_false
          end
        end
      end
    end # set_fields_among
  end # generic_fields


    describe "#fields_equal_among" do
      before(:each) do
        @st.visit("/form").should be_true
      end
      context "passes when" do
        context "text fields with labels" do
          it "sets one field" do
            @st.set_fields_among({"First name" => "Marcus"}).should be_true
            @st.fields_equal_among({"First name" => "Marcus"}).should be_true
          end

          it "sets one field with string ids" do
            @st.set_fields_among({"First name" => "Marcus"}, "").should be_true
            @st.fields_equal_among({"First name" => "Marcus"}, "").should be_true
          end

          it "does nothing, but has ids" do
            @st.fields_equal_among("", {"First name" => "Marcus"}).should be_true
          end

          it "sets several fields" do
            @st.set_fields_among({"First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot."}).should be_true
            @st.fields_equal_among({"First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot."}).should be_true
          end
        end
        context "text fields with labels in a hash" do
          it "sets one field from a hash" do
            @st.set_fields_among({"Faust name" => "Marcus"}, {"Faust Name" => "First name", "LOST name" => "Last name"}).should be_true
            @st.fields_equal_among({"Faust name" => "Marcus"}, {"Faust Name" => "First name", "LOST name" => "Last name"}).should be_true
          end

          it "sets many fields, some from a hash" do
            @st.set_fields_among({"Faust\\;name" => "Ken", :Lost => "Brazier", "Life story" => "I get testy a lot."},
                                 {"Faust\\;Name" => "First name", :LOST => "Last name"}).should be_true
            @st.fields_equal_among({"Faust\\;name" => "Ken", :Lost => "Brazier", "Life story" => "I get testy a lot."},
                                 {"Faust\\;Name" => "First name", :LOST => "Last name"}).should be_true
          end
        end
      end

      context "fails when" do
        context "text fields with labels" do
          it "cant find the first field" do
            @st.fields_equal_among({"Faust name" => "Ken", "Last name" => "Brazier"}).should be_false
          end

          it "cant find the last field" do
            @st.fields_equal_among({"First name" => "Ken", "Lost name" => "Brazier"}).should be_false
          end
          it "does not equal the expected values" do
            @st.fields_equal_among({"First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot."}).should be_false
          end
        end
        context "text fields with labels in a hash" do
          it "cant find the first field" do
            @st.fields_equal_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                                 {"Faust Name" => "Lost name", "Lost name" => "Last name"}).should be_false
          end

          it "cant find the last field" do
            @st.fields_equal_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                                 {"Faust Name" => "First name", "Lost name" => "Faust name"}).should be_false
          end
          it "does not equal the expected values" do
            @st.fields_equal_among({"Faust\\;name" => "Ken", :Lost => "Brazier", "Life story" => "I get testy a lot."},
                                 {"Faust\\;Name" => "First name", :LOST => "Last name"}).should be_false
          end
        end
      end
    end # set_fields_among
  end # generic_fields



  context "tables" do
    before(:each) do
      @st.visit("/table").should be_true
    end

    describe "#row_exists" do
      context "passes when" do
        it "full row of headings exists" do
          @st.row_exists("First name, Last name, Email").should be_true
        end

        it "partial row of headings exists" do
          @st.row_exists("First name, Last name").should be_true
          @st.row_exists("Last name, Email").should be_true
        end

        it "full row of cells exists" do
          @st.row_exists("Eric, Pierce, epierce@example.com").should be_true
        end

        it "partial row of cells exists" do
          @st.row_exists("Eric, Pierce").should be_true
          @st.row_exists("Pierce, epierce@example.com").should be_true
        end

        it "cell values are not consecutive" do
          @st.row_exists("First name, Email").should be_true
          @st.row_exists("Eric, epierce@example.com").should be_true
        end
      end

      context "fails when" do
        it "no row exists" do
          @st.row_exists("Middle name, Maiden name, Email").should be_false
        end
      end
    end

  end # tables


  context "waiting" do
    before(:each) do
      @st.visit("/").should be_true
    end

    describe "#page_loads_in_seconds_or_less" do
      context "passes when" do
        it "page is already loaded" do
          @st.click_link("About this site").should be_true
          sleep 1
          @st.page_loads_in_seconds_or_less(10).should be_true
        end
        it "page loads before the timeout" do
          @st.click_link("Slow page").should be_true
          @st.page_loads_in_seconds_or_less(10).should be_true
          @st.see("This page takes a few seconds to load").should be_true
        end
      end

      context "fails when" do
        it "slow page does not load before the timeout" do
          @st.click_link("Slow page").should be_true
          @st.page_loads_in_seconds_or_less(1).should be_false
        end
      end
    end

    describe "#pause_seconds" do
      it "returns true" do
        @st.pause_seconds(0).should == true
        @st.pause_seconds(1).should == true
      end
    end
  end # waiting


  context "method inspection" do
    describe "respond_to?" do
      it "returns true if a method is explicitly defined" do
        @st.respond_to?('see').should == true
      end

      it "returns true if the Selenium::Client::Driver defines the method" do
        @st.respond_to?('is_element_present').should == true
      end

      it "returns false if the method isn't defined" do
        @st.respond_to?('junk').should == false
      end
    end
  end


  context "stop on failure" do
    before(:each) do
      @st.visit("/").should be_true
      @st.stop_on_failure = true
      @st.found_failure = false
    end

    after(:each) do
      @st.stop_on_failure = false
    end

    context "causes subsequent steps to fail" do
      it "when #see fails" do
        @st.see("Nonexistent").should be_false
        # Would pass, but previous step failed
        @st.see("Welcome").should be_false
      end

      it "when #do_not_see fails" do
        @st.do_not_see("Welcome").should be_false
        # Would pass, but previous step failed
        @st.do_not_see("Nonexistent").should be_false
      end

      it "when #see_title fails" do
        @st.errors # clear errors
        @st.see_title("Wrong Title").should be_false
        # Would pass, but previous step failed
        @st.see_title("Rsel Test Site").should be_false
        # Should see one and only one error.
        @st.errors.should eq("Page title is 'Rsel Test Site', not 'Wrong Title'")
      end

      it "when #do_not_see_title fails" do
        @st.do_not_see_title("Rsel Test Site").should be_false
        # Would pass, but previous step failed
        @st.do_not_see_title("Wrong title").should be_false
      end

      it "when #link_exists fails" do
        @st.link_exists("Bogus Link").should be_false
        # Would pass, but previous step failed
        @st.link_exists("About this site").should be_false
      end

      it "when #button_exists fails" do
        @st.visit("/form").should be_true
        @st.button_exists("Bogus Button").should be_false
        # Would pass, but previous step failed
        @st.button_exists("Submit person form").should be_false
      end

      it "when #row_exists fails" do
        @st.visit("/table").should be_true
        @st.row_exists("No, Such, Row").should be_false
        # Would pass, but previous step failed
        @st.row_exists("First name, Last name, Email").should be_false
      end

      it "when #type_into_field fails" do
        @st.visit("/form").should be_true
        @st.type_into_field("Hello", "Bad Field").should be_false
        # Would pass, but previous step failed
        @st.type_into_field("Eric", "First name").should be_false
      end

      it "when #field_contains fails" do
        @st.visit("/form").should be_true
        @st.field_contains("Bad Field", "Hello").should be_false
        # Would pass, but previous step failed
        @st.field_contains("First name", "Marcus").should be_false
      end

      it "when #field_equals fails" do
        @st.visit("/form").should be_true
        @st.fill_in_with("First name", "Ken")
        @st.field_equals("First name", "Eric").should be_false
        # Would pass, but previous step failed
        @st.field_equals("First name", "Ken").should be_false
      end

      it "when #click fails" do
        @st.click("No Such Link").should be_false
        # Would pass, but previous step failed
        @st.click("About this site").should be_false
      end

      it "when #click_link fails" do
        @st.click_link("No Such Link").should be_false
        # Would pass, but previous step failed
        @st.click_link("About this site").should be_false
      end

      it "when #click_button fails" do
        @st.visit("/form").should be_true
        @st.click_button("No Such Link").should be_false
        # Would pass, but previous step failed
        @st.click_button("Submit person form").should be_false
      end

      it "when #enable_checkbox fails" do
        @st.visit("/form").should be_true
        @st.enable_checkbox("No Such Checkbox").should be_false
        # Would pass, but previous step failed
        @st.enable_checkbox("I like cheese").should be_false
      end

      it "when #disable_checkbox fails" do
        @st.visit("/form").should be_true
        @st.disable_checkbox("No Such Checkbox").should be_false
        # Would pass, but previous step failed
        @st.disable_checkbox("I like cheese").should be_false
      end

      it "when #checkbox_is_enabled fails" do
        @st.visit("/form").should be_true
        @st.enable_checkbox("I like cheese").should be_true
        @st.checkbox_is_enabled("No Such Checkbox").should be_false
        # Would pass, but previous step failed
        @st.checkbox_is_enabled("I like cheese").should be_false
      end

      it "when #checkbox_is_disabled fails" do
        @st.visit("/form").should be_true
        @st.checkbox_is_disabled("No Such Checkbox").should be_false
        # Would pass, but previous step failed
        @st.checkbox_is_disabled("I like cheese").should be_false
      end

      it "when #radio_is_enabled fails" do
        @st.visit("/form").should be_true
        @st.select_radio("Briefs").should be_true
        @st.radio_is_enabled("No Such Radio").should be_false
        # Would pass, but previous step failed
        @st.radio_is_enabled("Briefs").should be_false
      end

      it "when #radio_is_disabled fails" do
        @st.visit("/form").should be_true
        @st.select_radio("Boxers").should be_true
        @st.radio_is_disabled("No Such Radio").should be_false
        # Would pass, but previous step failed
        @st.radio_is_disabled("Briefs").should be_false
      end

      it "when #select_radio fails" do
        @st.visit("/form").should be_true
        @st.select_radio("No Such Radio").should be_false
        # Would pass, but previous step failed
        @st.select_radio("Boxers").should be_false
      end

      it "when #select_from_dropdown fails" do
        @st.visit("/form").should be_true
        @st.select_from_dropdown("Junk", "No Such Dropdown").should be_false
        # Would pass, but previous step failed
        @st.select_from_dropdown("Tall", "Height").should be_false
      end

      it "when #dropdown_includes fails" do
        @st.visit("/form").should be_true
        @st.dropdown_includes("No Such Dropdown", "Junk").should be_false
        # Would pass, but previous step failed
        @st.dropdown_includes("Height", "Tall").should be_false
      end

      it "when #dropdown_equals fails" do
        @st.visit("/form").should be_true
        @st.select_from_dropdown("Tall", "Height").should be_true
        @st.dropdown_equals("No Such Dropdown", "Junk").should be_false
        # Would pass, but previous step failed
        @st.dropdown_equals("Tall", "Height").should be_false
      end
    end

    context "can be reset with #begin_scenario" do
      it "when #see fails" do
        @st.see("Nonexistent").should be_false
        # Would pass, but previous step failed
        @st.see("Welcome").should be_false
        # Starting a new scenario allows #see to pass
        @st.begin_scenario
        @st.see("Welcome").should be_true
      end

      it "when #do_not_see fails" do
        @st.do_not_see("Welcome").should be_false
        # Would pass, but previous step failed
        @st.do_not_see("Nonexistent").should be_false
        # Starting a new scenario allows #do_not_see to pass
        @st.begin_scenario
        @st.do_not_see("Nonexistent").should be_true
      end
    end

  end # stop on failure


  context "Selenium::Client::Driver wrapper" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    context "method returning Boolean" do
      it "passes if method returns true" do
        @st.is_element_present("id=first_name").should be_true
        @st.is_visible("id=first_name").should be_true
        @st.is_text_present("This page has some random forms").should be_true
      end

      it "fails if method returns false" do
        @st.is_element_present("id=bogus_id").should be_false
        @st.is_visible("id=bogus_id").should be_false
        @st.is_text_present("This text is not there").should be_false
      end
    end

    context "method returning String" do
      it "returns the String" do
        @st.get_text("id=salami_checkbox").should eq("I like salami")
      end
    end

    context "method not returning Boolean or String" do
      it "passes if method doesn't raise an exception" do
        @st.get_title.should be_true
        @st.mouse_over("id=first_name").should be_true
      end

      it "fails if method raises an exception" do
        @st.double_click("id=bogus_id").should be_false
        @st.mouse_over("id=bogus_id").should be_false
      end
    end
  end # Selenium::Client::Driver wrapper

end

