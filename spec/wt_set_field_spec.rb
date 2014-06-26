require_relative 'wt_spec_helper'

describe "#set_field" do
  context "fields" do
    before(:each) do
      @wt.visit("/form").should be_true
    end

    context "#set_field with #type_into_field" do
      context "passes when" do
        context "text field with label" do
          it "exists" do
            @wt.set_field("First name", "Eric").should be_true
            @wt.set_field("Last name", "Pierce").should be_true
            @wt.field_contains("First name", "Eric").should be_true
            @wt.field_contains("Last name", "Pierce").should be_true
          end
          it "exists within scope" do
            @wt.set_field("First name", "Eric", :within => 'person_form').should be_true
            @wt.set_field("First name", "Andrea", :within => 'spouse_form').should be_true
          end
        end

        context "text field with id" do
          it "exists" do
            @wt.set_field("first_name", "Eric").should be_true
            @wt.set_field("last_name", "Pierce").should be_true
            @wt.field_contains("first_name", "Eric").should be_true
            @wt.field_contains("last_name", "Pierce").should be_true
          end
        end

        context "textarea with label" do
          it "exists" do
            @wt.set_field("Life story", "Blah blah blah").should be_true
            @wt.set_field("Life story", "Jibber jabber").should be_true
            @wt.field_contains("Life story", "Jibber jabber").should be_true
          end
        end

        context "textarea with id" do
          it "exists" do
            @wt.set_field("biography", "Blah blah blah").should be_true
            @wt.set_field("biography", "Jibber jabber").should be_true
            @wt.field_contains("biography", "Jibber jabber").should be_true
          end
        end

        context "text field with name but duplicate id" do
          it "exists" do
            @wt.set_field("second_duplicate", "Jibber jabber").should be_true
            @wt.field_contains("first_duplicate", "").should be_true
            @wt.field_contains("second_duplicate", "Jibber jabber").should be_true
          end
        end

        it "clears a field" do
          @wt.field_contains("message", "Your message goes here").should be_true
          @wt.set_field("message","").should be_true
          @wt.field_contains("message", "").should be_true
        end
      end

      context "fails when" do
        it "no field with the given label or id exists" do
          @wt.set_field("Middle name", "Matthew").should be_false
          @wt.set_field("middle_name", "Matthew").should be_false
        end

        it "field exists, but not within scope" do
          @wt.set_field("Life story", "Long story",
                        :within => 'spouse_form').should be_false
        end

        it "field exists, but is read-only" do
          @wt.visit("/readonly_form").should be_true
          @wt.set_field("First name", "Eric").should be_false
        end

        it "field exists but is hidden" do
          #pending "selenium-client thinks hidden fields are editable" do
            # FIXME: This test fails, because the selenium-client 'is_editable'
            # method returns true for hidden fields. Rsel should work around
            # this; hidden fields should not be editable.
            @wt.set_field("secret", "whisper").should be_false
          #end
        end
      end
    end # set_field with type_into_field

    context "#set_field with #field_contains" do
      context "passes when" do
        context "text field with label" do
          it "equals the text" do
            @wt.set_field("First name", "Marcus")
            @wt.field_contains("First name", "Marcus").should be_true
          end

          it "contains the text" do
            @wt.set_field("First name", "Marcus")
            @wt.field_contains("First name", "Marc").should be_true
          end
        end

        context "textarea with label" do
          it "contains the text" do
            @wt.set_field("Life story", "Blah dee blah")
            @wt.field_contains("Life story", "blah").should be_true
          end
        end
      end

      context "fails when" do
        context "text field with label" do
          it "does not contain the text" do
            @wt.set_field("First name", "Marcus")
            @wt.field_contains("First name", "Eric").should be_false
          end
        end

        context "textarea with label" do
          it "does not contain the text" do
            @wt.set_field("Life story", "Blah dee blah")
            @wt.field_contains("Life story", "spam").should be_false
          end
        end
      end
    end # set_field with field_contains

    context "#set_field with #generic_field_equals" do
      context "passes when" do
        context "text field with label" do
          it "equals the text" do
            @wt.set_field("First name", "Ken")
            @wt.generic_field_equals("First name", "Ken").should be_true
          end

          it "equals the text, and is within scope" do
            @wt.set_field("First name", "Eric", :within => "person_form")
            @wt.generic_field_equals("First name", "Eric", :within => "person_form")
          end
        end

        context "textarea with label" do
          it "equals the text" do
            @wt.set_field("Life story", "Blah dee blah")
            @wt.generic_field_equals("Life story", "Blah dee blah").should be_true
          end

          it "equals the text, and is within scope" do
            @wt.set_field("Life story", "Blah dee blah",
                          :within => "person_form")
            @wt.generic_field_equals("Life story", "Blah dee blah",
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
            @wt.set_field("First name", "Marcus")
            @wt.generic_field_equals("First name", "Marc").should be_false
          end
        end

        context "text field with id" do
          it "exactly equals the text, but is an unsupported type" do
            #pending "hidden fields should be unsupported" do
              # FIXME: This test fails, because generic_field_equals does
              # in fact allow inspecting the value of a hidden field.
              @wt.generic_field_equals("secret", "psst").should be_false
            #end
          end
        end

        context "textarea with label" do
          it "does not exist" do
            @wt.generic_field_equals("Third name", "Smith").should be_false
          end

          it "does not exactly equal the text" do
            @wt.set_field("Life story", "Blah dee blah")
            @wt.generic_field_equals("Life story", "Blah dee").should be_false
          end

          it "exactly equals the text, but is not within scope" do
            @wt.set_field("First name", "Eric", :within => "person_form")
            @wt.generic_field_equals("First name", "Eric", :within => "spouse_form").should be_false
          end

          it "exactly equals the text, but is not in table row" do
            # TODO
          end
        end
      end
    end # set_field with generic_field_equals
  end # fields


  context "checkboxes" do
    before(:each) do
      @wt.visit("/form").should be_true
    end

    context "#set_field with #enable_checkbox" do
      context "passes when" do
        context "checkbox with label" do
          it "exists" do
            @wt.set_field("I like cheese", "on").should be_true
            @wt.set_field("I like salami", "on").should be_true
            @wt.generic_field_equals("I like cheese", "on").should be_true
            @wt.generic_field_equals("I like salami", "on").should be_true
          end

          it "exists and is already checked" do
            @wt.set_field("I like cheese", "on").should be_true
            @wt.set_field("I like cheese", "on").should be_true
            @wt.generic_field_equals("I like cheese", "on").should be_true
          end

          it "exists within scope" do
            @wt.set_field("I like cheese", "on", :within => "cheese_checkbox").should be_true
            @wt.set_field("I like salami", "on", :within => "salami_checkbox").should be_true
            @wt.generic_field_equals("I like cheese", "on", :within => "cheese_checkbox").should be_true
            @wt.generic_field_equals("I like salami", "on", :within => "salami_checkbox").should be_true
          end

          it "exists in table row" do
            @wt.visit("/table")
            @wt.set_field("Like", "on", :in_row => "Marcus").should be_true
            @wt.generic_field_equals("Like", "on", :in_row => "Marcus").should be_true
          end
        end

        context "checkbox with id=" do
          it "exists" do
            @wt.set_field("id=like_cheese", "on").should be_true
            @wt.generic_field_equals("id=like_cheese", "on").should be_true
          end
        end

        context "checkbox with xpath=" do
          it "exists" do
            @wt.set_field("xpath=//input[@id='like_cheese']", "on").should be_true
            @wt.generic_field_equals("xpath=//input[@id='like_cheese']", "on").should be_true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            @wt.set_field("I dislike bacon", "on").should be_false
            @wt.set_field("I like broccoli", "on").should be_false
          end

          it "exists, but not within scope" do
            @wt.set_field("I like cheese", "on", :within => "salami_checkbox").should be_false
            @wt.set_field("I like salami", "on", :within => "cheese_checkbox").should be_false
          end

          it "exists, but not in table row" do
            @wt.visit("/table")
            @wt.set_field("Like", "on", :in_row => "Eric").should be_false
          end

          it "exists, but is read-only" do
            @wt.visit("/readonly_form").should be_true
            @wt.set_field("I like salami", "on").should be_false
          end
        end
      end
    end # set_field with enable_checkbox

    context "#set_field with #disable_checkbox" do
      context "passes when" do
        context "checkbox with label" do
          it "exists" do
            @wt.set_field("I like cheese", "off").should be_true
            @wt.set_field("I like salami", "off").should be_true
            @wt.generic_field_equals("I like cheese", "off").should be_true
            @wt.generic_field_equals("I like salami", "off").should be_true
          end

          it "exists and is already unchecked" do
            @wt.set_field("I like cheese", "off").should be_true
            @wt.set_field("I like cheese", "off").should be_true
            @wt.generic_field_equals("I like cheese", "off").should be_true
          end

          it "exists within scope" do
            @wt.set_field("I like cheese", "off", :within => "cheese_checkbox").should be_true
            @wt.set_field("I like salami", "off", :within => "preferences_form").should be_true
            @wt.generic_field_equals("I like cheese", "off", :within => "cheese_checkbox").should be_true
            @wt.generic_field_equals("I like salami", "off", :within => "preferences_form").should be_true
          end

          it "exists in table row" do
            @wt.visit("/table")
            @wt.set_field("Like", "off", :in_row => "Marcus").should be_true
            @wt.generic_field_equals("Like", "off", :in_row => "Marcus").should be_true
          end
        end

        context "checkbox with id=" do
          it "exists" do
            @wt.set_field("id=like_cheese", "off").should be_true
            @wt.generic_field_equals("id=like_cheese", "off").should be_true
          end
        end

        context "checkbox with xpath=" do
          it "exists" do
            @wt.set_field("xpath=//input[@id='like_cheese']", "off").should be_true
            @wt.generic_field_equals("xpath=//input[@id='like_cheese']", "off").should be_true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            @wt.set_field("I dislike bacon", "off").should be_false
            @wt.set_field("I like broccoli", "off").should be_false
          end

          it "exists, but not within scope" do
            @wt.set_field("I like cheese", "off", :within => "salami_checkbox").should be_false
            @wt.set_field("I like salami", "off", :within => "cheese_checkbox").should be_false
          end

          it "exists, but not in table row" do
            @wt.visit("/table")
            @wt.set_field("Like", "off", :in_row => "Eric").should be_false
          end

          it "exists, but is read-only" do
            @wt.visit("/readonly_form").should be_true
            @wt.set_field("I like cheese", "off").should be_false
          end
        end
      end
    end # set_field with disable_checkbox

    context "#set_field with #checkbox_is_enabled" do
      context "passes when" do
        context "checkbox with label" do
          it "exists and is checked" do
            @wt.set_field("I like cheese", "on").should be_true
            @wt.checkbox_is_enabled("I like cheese").should be_true
          end

          it "exists within scope and is checked" do
            @wt.set_field("I like cheese", "on", :within => "cheese_checkbox").should be_true
            @wt.checkbox_is_enabled("I like cheese", :within => "cheese_checkbox").should be_true
          end

          it "exists in table row and is checked" do
            @wt.visit("/table")
            @wt.set_field("Like", "on", :in_row => "Ken").should be_true
            @wt.checkbox_is_enabled("Like", :in_row => "Ken").should be_true
          end

          it "exists and is checked, but read-only" do
            @wt.visit("/readonly_form").should be_true
            @wt.checkbox_is_enabled("I like cheese").should be_true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            @wt.checkbox_is_enabled("I dislike bacon").should be_false
          end

          it "exists but is unchecked" do
            @wt.set_field("I like cheese", "off").should be_true
            @wt.checkbox_is_enabled("I like cheese").should be_false
          end

          it "exists and is checked, but not within scope" do
            @wt.set_field("I like cheese", "on", :within => "cheese_checkbox").should be_true
            @wt.checkbox_is_enabled("I like cheese", :within => "salami_checkbox").should be_false
          end

          it "exists and is checked, but not in table row" do
            @wt.visit("/table")
            @wt.set_field("Like", "on", :in_row => "Marcus").should be_true
            @wt.checkbox_is_enabled("Like", :in_row => "Eric").should be_false
          end
        end
      end
    end # set_field with checkbox_is_enabled

    context "#set_field with #checkbox_is_disabled" do
      context "passes when" do
        context "checkbox with label" do
          it "exists and is unchecked" do
            @wt.set_field("I like cheese", "off").should be_true
            @wt.checkbox_is_disabled("I like cheese").should be_true
          end

          it "exists within scope and is unchecked" do
            @wt.set_field("I like cheese", "off", :within => "cheese_checkbox").should be_true
            @wt.checkbox_is_disabled("I like cheese", :within => "cheese_checkbox").should be_true
          end

          it "exists in table row and is unchecked" do
            @wt.visit("/table")
            @wt.set_field("Like", "off", :in_row => "Ken").should be_true
            @wt.checkbox_is_disabled("Like", :in_row => "Ken").should be_true
          end

          it "exists and is unchecked, but read-only" do
            @wt.visit("/readonly_form").should be_true
            @wt.checkbox_is_disabled("I like salami").should be_true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            @wt.checkbox_is_disabled("I dislike bacon").should be_false
          end

          it "exists but is checked" do
            @wt.set_field("I like cheese", "on").should be_true
            @wt.checkbox_is_disabled("I like cheese").should be_false
          end

          it "exists and is unchecked, but not within scope" do
            @wt.set_field("I like cheese", "off", :within => "cheese_checkbox").should be_true
            @wt.checkbox_is_disabled("I like cheese", :within => "salami_checkbox").should be_false
          end

          it "exists and is unchecked, but not in table row" do
            @wt.visit("/table")
            @wt.set_field("Like", "off", :in_row => "Marcus").should be_true
            @wt.checkbox_is_disabled("Like", :in_row => "Eric").should be_false
          end
        end
      end
    end # set_field with checkbox_is_disabled
  end # checkboxes


  context "radiobuttons" do
    before(:each) do
      @wt.visit("/form").should be_true
    end

    context "#set_field with #select_radio" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists" do
            @wt.set_field("Briefs").should be_true
          end

          it "exists within scope" do
            @wt.set_field("Briefs", "", :within => "clothing").should be_true
          end

          it "exists in table row" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            @wt.set_field("Naked", "").should be_false
          end

          it "exists, but not within scope" do
            @wt.set_field("Briefs", "", :within => "food").should be_false
          end

          it "exists, but is read-only" do
            @wt.visit("/readonly_form").should be_true
            @wt.set_field("Boxers", "").should be_false
          end

          it "exists, but not in table row" do
            # TODO
          end
        end
      end
    end # set_field with select_radio

    context "#set_field with #radio_is_enabled" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists, and is enabled" do
            @wt.set_field("Briefs")
            @wt.radio_is_enabled("Briefs").should be_true
          end

          it "exists within scope, and is enabled" do
            @wt.set_field("Briefs", "", :within => "clothing")
            @wt.radio_is_enabled("Briefs", :within => "clothing").should be_true
          end

          it "exists in table row, and is enabled" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            @wt.radio_is_enabled("Naked").should be_false
          end

          it "exists, but is not enabled" do
            @wt.set_field("Briefs", "")
            @wt.radio_is_enabled("Boxers").should be_false
          end

          it "exists and is enabled, but not within scope" do
            @wt.set_field("Briefs", "", :within => "clothing")
            @wt.radio_is_enabled("Briefs", :within => "food").should be_false
          end
        end
      end
    end # set_field with radio_is_enabled

    context "#set_field with #generic_field_equals for #radio_is_enabled" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists, and is enabled" do
            @wt.set_field("Briefs")
            @wt.generic_field_equals("Briefs", "on").should be_true
          end

          it "exists within scope, and is enabled" do
            @wt.set_field("Briefs", "", :within => "clothing")
            @wt.generic_field_equals("Briefs", "on", :within => "clothing").should be_true
          end

          it "exists in table row, and is enabled" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            @wt.generic_field_equals("Naked", "on").should be_false
          end

          it "exists, but is not enabled" do
            @wt.set_field("Briefs", "")
            @wt.generic_field_equals("Boxers", "on").should be_false
          end

          it "exists and is enabled, but not within scope" do
            @wt.set_field("Briefs", "", :within => "clothing")
            @wt.generic_field_equals("Briefs", "on", :within => "food").should be_false
          end
        end
      end
    end # set_field with generic_field_equals for radio_is_enabled

    context "#set_field with #generic_field_equals for #radio_is_disabled" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists, and is disabled" do
            @wt.set_field("Boxers")
            @wt.generic_field_equals("Briefs", "off").should be_true
          end

          it "exists within scope, and is disabled" do
            @wt.set_field("Boxers", "", :within => "clothing")
            @wt.generic_field_equals("Briefs", "off", :within => "clothing").should be_true
          end

          it "exists in table row, and is enabled" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            @wt.generic_field_equals("Naked", "off").should be_false
          end

          it "exists, but is enabled" do
            @wt.set_field("Briefs", "")
            @wt.generic_field_equals("Briefs", "off").should be_false
          end

          it "exists and is disabled, but not within scope" do
            @wt.set_field("Boxers", "", :within => "clothing")
            @wt.generic_field_equals("Briefs", "off", :within => "food").should be_false
          end
        end
      end
    end # set_field with generic_field_equals for radio_is_disabled
  end # radiobuttons


  context "dropdowns" do
    before(:each) do
      @wt.visit("/form").should be_true
    end

    context "#set_field with #select_from_dropdown" do
      context "passes when" do
        it "option exists in the dropdown" do
          @wt.set_field("Height", "Tall").should be_true
          @wt.set_field("Weight", "Medium").should be_true
        end

        it "option exists in the dropdown within scope" do
          @wt.set_field("Height", "Tall", :within => "spouse_form").should be_true
        end

        it "option exists in the dropdown in table row" do
          @wt.visit("/table")
          @wt.set_field("Gender", "Male", :in_row => "Eric").should be_true
        end
      end

      context "fails when" do
        it "no such dropdown exists" do
          @wt.set_field("Eggs", "Over easy").should be_false
        end

        it "dropdown exists, but the option doesn't" do
          @wt.set_field("Height", "Giant").should be_false
          @wt.set_field("Weight", "Obese").should be_false
        end

        it "dropdown exists, but is read-only" do
          @wt.visit("/readonly_form").should be_true
          @wt.set_field("Height", "Tall").should be_false
        end

        it "dropdown exists, but not within scope" do
          @wt.set_field("Weight", "Medium", :within => "spouse_form").should be_false
        end

        it "dropdown exists, but not in table row" do
          @wt.visit("/table")
          @wt.set_field("Gender", "Female", :in_row => "First name").should be_false
        end
      end
    end # set_field with select_from_dropdown

    context "#set_field with #dropdown_includes" do
      context "passes when" do
        it "option exists in the dropdown" do
          @wt.dropdown_includes("Height", "Tall").should be_true
          @wt.dropdown_includes("Weight", "Medium").should be_true
        end

        it "option exists in a read-only dropdown" do
          @wt.visit("/readonly_form").should be_true
          @wt.dropdown_includes("Height", "Tall").should be_true
        end
      end

      context "fails when" do
        it "dropdown exists, but the option doesn't" do
          @wt.dropdown_includes("Height", "Giant").should be_false
          @wt.dropdown_includes("Weight", "Obese").should be_false
        end

        it "no such dropdown exists" do
          @wt.dropdown_includes("Eggs", "Over easy").should be_false
        end
      end
    end # set_field with dropdown_includes

    context "#set_field with #dropdown_equals" do
      context "passes when" do
        it "option is selected in the dropdown" do
          ["Short", "Average", "Tall"].each do |height|
            @wt.set_field("Height", height)
            @wt.dropdown_equals("Height", height).should be_true
          end
        end

        it "option is selected in a read-only dropdown" do
          @wt.visit("/readonly_form").should be_true
          @wt.dropdown_equals("Height", "Average").should be_true
        end

        it "option is selected in the dropdown, within scope" do
          ["Short", "Average", "Tall"].each do |height|
            @wt.set_field("Height", height, :within => "spouse_form")
            @wt.dropdown_equals("Height", height, :within => "spouse_form").should be_true
          end
        end

        it "option is selected in the dropdown, in table row" do
          @wt.visit("/table")
          ["Male", "Female"].each do |gender|
            @wt.set_field("Gender", gender, :in_row => "Eric")
            @wt.dropdown_equals("Gender", gender, :in_row => "Eric")
          end
        end
      end

      context "fails when" do
        it "no such dropdown exists" do
          @wt.dropdown_equals("Eggs", "Over easy").should be_false
        end

        it "dropdown exists, but the option is not selected" do
          @wt.set_field("Height", "Short")
          @wt.dropdown_equals("Height", "Average").should be_false
          @wt.dropdown_equals("Height", "Tall").should be_false

          @wt.set_field("Height", "Average")
          @wt.dropdown_equals("Height", "Short").should be_false
          @wt.dropdown_equals("Height", "Tall").should be_false

          @wt.set_field("Height", "Tall")
          @wt.dropdown_equals("Height", "Short").should be_false
          @wt.dropdown_equals("Height", "Average").should be_false
        end

        it "dropdown exists, and option is selected, but not within scope" do
          @wt.set_field("Height", "Tall", :within => "person_form")
          @wt.set_field("Height", "Short", :within => "spouse_form")
          @wt.dropdown_equals("Height", "Tall", :within => "spouse_form").should be_false
        end

        it "dropdown exists, and option is selected, but not in table row" do
          @wt.visit("/table")
          @wt.set_field("Gender", "Female", :in_row => "Eric")
          @wt.set_field("Gender", "Male", :in_row => "Marcus")
          @wt.dropdown_equals("Gender", "Female", :in_row => "Marcus").should be_false
        end
      end
    end # set_field with dropdown_equals

    context "#set_field with #generic_field_equals for #dropdown_equals" do
      context "passes when" do
        it "option is selected in the dropdown" do
          ["Short", "Average", "Tall"].each do |height|
            @wt.set_field("Height", height)
            @wt.generic_field_equals("Height", height).should be_true
          end
        end

        it "option is selected in a read-only dropdown" do
          @wt.visit("/readonly_form").should be_true
          @wt.generic_field_equals("Height", "Average").should be_true
        end

        it "option is selected in the dropdown, within scope" do
          ["Short", "Average", "Tall"].each do |height|
            @wt.set_field("Height", height, :within => "spouse_form")
            @wt.generic_field_equals("Height", height, :within => "spouse_form").should be_true
          end
        end

        it "option is selected in the dropdown, in table row" do
          @wt.visit("/table")
          ["Male", "Female"].each do |gender|
            @wt.set_field("Gender", gender, :in_row => "Eric").should be_true
            @wt.generic_field_equals("Gender", gender, :in_row => "Eric")
          end
        end
      end

      context "fails when" do
        it "no such dropdown exists" do
          @wt.generic_field_equals("Eggs", "Over easy").should be_false
        end

        it "dropdown exists, but the option is not selected" do
          @wt.set_field("Height", "Short")
          @wt.generic_field_equals("Height", "Average").should be_false
          @wt.generic_field_equals("Height", "Tall").should be_false

          @wt.set_field("Height", "Average")
          @wt.generic_field_equals("Height", "Short").should be_false
          @wt.generic_field_equals("Height", "Tall").should be_false

          @wt.set_field("Height", "Tall")
          @wt.generic_field_equals("Height", "Short").should be_false
          @wt.generic_field_equals("Height", "Average").should be_false
        end

        it "dropdown exists, and option is selected, but not within scope" do
          @wt.set_field("Height", "Tall", :within => "person_form").should be_true
          @wt.set_field("Height", "Short", :within => "spouse_form").should be_true
          @wt.generic_field_equals("Height", "Tall", :within => "spouse_form").should be_false
        end

        it "dropdown exists, and option is selected, but not in table row" do
          @wt.visit("/table")
          @wt.set_field("Gender", "Female", :in_row => "Eric").should be_true
          @wt.set_field("Gender", "Male", :in_row => "Marcus").should be_true
          @wt.generic_field_equals("Gender", "Female", :in_row => "Marcus").should be_false
        end
      end
    end # set_field with generic_field_equals for dropdown_equals
  end # dropdowns


  context "#set_field with button click" do
    before(:each) do
      @wt.visit("/form").should be_true
    end

    it "clicks a button" do
      @wt.set_field("Submit person form", "clicked").should be_true
      @wt.page_loads_in_seconds_or_less(10).should be_true
      @wt.see("We appreciate your feedback").should be_true
    end
  end

  context "#set_field with link click" do
    before(:each) do
      @wt.visit("/").should be_true
    end
    it "clicks a link" do
      @wt.set_field("About this site", "clicked").should be_true
      @wt.page_loads_in_seconds_or_less(10).should be_true
      @wt.see("This site is really cool.").should be_true
    end
  end

end # set_field


