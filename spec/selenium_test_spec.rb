require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Rsel::SeleniumTest do
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


  context "checkbox" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    describe "#enable_checkbox" do
      context "passes when" do
        it "checkbox with the given label is present" do
          @st.enable_checkbox("I like cheese").should be_true
          @st.enable_checkbox("I like salami").should be_true
        end
      end

      context "fails when" do
        it "checkbox with the given label is absent" do
          @st.enable_checkbox("I dislike bacon").should be_false
          @st.enable_checkbox("I like broccoli").should be_false
        end
      end
    end

    describe "#disable_checkbox" do
      context "passes when" do
        it "checkbox with the given label is present" do
          @st.disable_checkbox("I like cheese").should be_true
          @st.disable_checkbox("I like salami").should be_true
        end
      end
      context "fails when" do
        it "checkbox with the given label is absent" do
          @st.disable_checkbox("I dislike bacon").should be_false
          @st.disable_checkbox("I like broccoli").should be_false
        end
      end
    end

    describe "#checkbox_is_enabled" do
      context "passes when" do
        it "checkbox with the given label exists and is checked" do
          @st.enable_checkbox("I like cheese").should be_true
          @st.checkbox_is_enabled("I like cheese").should be_true
        end
      end

      context "fails when" do
        it "checkbox with the given label exists but is unchecked" do
          @st.disable_checkbox("I like cheese").should be_true
          @st.checkbox_is_enabled("I like cheese").should be_false
        end

        it "checkbox with the given label does not exist" do
          @st.checkbox_is_enabled("I dislike bacon").should be_false
        end
      end
    end

    describe "#checkbox_is_disabled" do
      context "passes when" do
        it "checkbox with the given label exists and is unchecked" do
          @st.disable_checkbox("I like cheese").should be_true
          @st.checkbox_is_disabled("I like cheese").should be_true
        end
      end

      context "fails when" do
        it "checkbox with the given label exists but is checked" do
          @st.enable_checkbox("I like cheese").should be_true
          @st.checkbox_is_disabled("I like cheese").should be_false
        end

        it "checkbox with the given label does not exist" do
          @st.checkbox_is_disabled("I dislike bacon").should be_false
        end
      end
    end
  end


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
      end

      context "fails when" do
        it "dropdown exists, but the option doesn't" do
          @st.select_from_dropdown("Giant", "Height").should be_false
          @st.select_from_dropdown("Obese", "Weight").should be_false
        end

        it "no such dropdown exists" do
          @st.select_from_dropdown("Over easy", "Eggs").should be_false
        end
      end
    end

    context "#dropdown_includes" do
      context "passes when" do
        it "option exists in the dropdown" do
          @st.dropdown_includes("Height", "Tall").should be_true
          @st.dropdown_includes("Weight", "Medium").should be_true
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
          @st.select_from_dropdown("Short", "Height")
          @st.dropdown_equals("Height", "Short").should be_true

          @st.select_from_dropdown("Average", "Height")
          @st.dropdown_equals("Height", "Average").should be_true

          @st.select_from_dropdown("Tall", "Height")
          @st.dropdown_equals("Height", "Tall").should be_true
        end
      end

      context "fails when" do
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

        it "no such dropdown exists" do
          @st.dropdown_equals("Eggs", "Over easy").should be_false
        end
      end
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

      context "fails when" do
        it "page does not exist" do
          @st.visit("/bad/path").should be_false
        end
      end
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
  end


  context "links" do
    before(:each) do
      @st.visit("/").should be_true
    end

    describe "#click_link" do
      context "passes when" do
        it "link exists" do
          @st.click_link("About this site").should be_true
        end

        it "link exists within scope" do
          @st.click_link("About this site", :within => "header").should be_true
        end
      end

      context "fails when" do
        it "link does not exist" do
          @st.click_link("Bogus link").should be_false
        end

        it "link exists, but within different scope" do
          @st.click_link("About this site", :within => "footer").should be_false
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

        it "link exists, but within different scope" do
          @st.link_exists("About this site", :within => "footer").should be_false
          @st.link_exists("Form test", :within => "header").should be_false
          @st.link_exists("Table test", :within => "header").should be_false
        end
      end
    end
  end


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
      end

      context "fails when" do
        it "button does not exist" do
          @st.click_button("No such button").should be_false
        end

        it "button exists, but within different scope" do
          @st.click_button("Submit person form", :within => "spouse_form").should be_false
        end

        it "button exists but is disabled" do
          # TODO
        end
      end
    end

    describe "#button_exists" do
      context "passes when" do
        it "button with the given text exists" do
          @st.button_exists("Submit person form").should be_true
          @st.button_exists("Save preferences").should be_true
        end

        it "button with the given text exists within scope" do
          @st.button_exists("Submit person form", :within => "person_form").should be_true
          @st.button_exists("Submit spouse form", :within => "spouse_form").should be_true
        end
      end

      context "fails when" do
        it "no such button exists" do
          @st.button_exists("Apple").should be_false
          @st.button_exists("Big Red").should be_false
        end

        it "button exists, but within different scope" do
          @st.button_exists("Submit spouse form", :within => "person_form").should be_false
          @st.button_exists("Submit person form", :within => "spouse_form").should be_false
        end
      end
    end
  end


  context "fields" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    describe "#type_into_field" do
      context "passes when" do
        it "text field with the given label exists" do
          @st.type_into_field("Eric", "First name").should be_true
          @st.fill_in_with("Last name", "Pierce").should be_true
        end

        it "text field with the given id exists" do
          @st.type_into_field("Eric", "first_name").should be_true
          @st.fill_in_with("last_name", "Pierce").should be_true
        end

        it "texarea with the given label exists" do
          @st.type_into_field("Blah blah blah", "Life story").should be_true
          @st.fill_in_with("Life story", "Jibber jabber").should be_true
        end

        it "texarea with the given id exists" do
          @st.type_into_field("Blah blah blah", "biography").should be_true
          @st.fill_in_with("biography", "Jibber jabber").should be_true
        end

        it "text field with the given label exists within scope" do
          @st.type_into_field("Eric", "First name", :within => 'person_form').should be_true
          @st.type_into_field("Andrea", "First name", :within => 'spouse_form').should be_true
        end
      end

      context "fails when" do
        it "no field with the given label or id exists" do
          @st.type_into_field("Matthew", "Middle name").should be_false
          @st.fill_in_with("middle_name", "Matthew").should be_false
        end

        it "field exists, but within different scope" do
          @st.type_into_field("Long story", "Life story", :within => 'spouse_form').should be_false
        end
      end
    end

    describe "#field_contains" do
      context "passes when" do
        it "textarea contains the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_contains("Life story", "blah").should be_true
        end
      end

      context "fails when" do
        it "textarea does not contain the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_contains("Life story", "spam").should be_false
        end
      end
    end

    describe "#field_equals" do
      context "passes when" do
        it "textarea equals the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_equals("Life story", "Blah dee blah").should be_true
        end
      end

      context "fails when" do
        it "textarea does not exactly equal the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_equals("Life story", "Blah dee").should be_false
        end
      end
    end
  end


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
          @st.see("Nonexistent").should be_false
          @st.see("Some bogus text").should be_false
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
        it "fails when test is present" do
          @st.do_not_see("Welcome").should be_false
          @st.do_not_see("This is a Sinatra webapp").should be_false
        end
      end

      it "is case-sensitive" do
        @st.do_not_see("Sinatra webapp").should be_false
        @st.do_not_see("sinatra Webapp").should be_true
      end
    end
  end


  context "tables" do
    before(:each) do
      @st.visit("/table").should be_true
    end

    describe "#row_exists" do
      context "passes when" do
        it "full row of headings exists" do
          @st.row_exists("First name, Last name, Nickname, Email").should be_true
        end

        it "partial row of headings exists" do
          @st.row_exists("First name, Last name").should be_true
          @st.row_exists("Nickname, Email").should be_true
        end

        it "full row of cells exists" do
          @st.row_exists("Eric, Pierce, epierce, epierce@example.com").should be_true
        end

        it "partial row of cells exists" do
          @st.row_exists("Eric, Pierce").should be_true
          @st.row_exists("epierce, epierce@example.com").should be_true
        end
      end

      context "fails when" do
        it "no row exists" do
          @st.row_exists("Middle name, Maiden name, Email").should be_false
        end

        it "cell values are not consecutive" do
          @st.row_exists("First name, Email").should be_false
          @st.row_exists("Eric, epierce").should be_false
        end
      end
    end
  end
end

