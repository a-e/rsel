require_relative 'st_spec_helper'

describe "#set_field" do
  context "fields" do
    before(:each) do
      expect(@st.visit("/form")).to be true
    end

    context "#set_field with #type_into_field" do
      context "passes when" do
        context "text field with label" do
          it "exists" do
            expect(@st.set_field("First name", "Eric")).to be true
            expect(@st.set_field("Last name", "Pierce")).to be true
            expect(@st.field_contains("First name", "Eric")).to be true
            expect(@st.field_contains("Last name", "Pierce")).to be true
          end
          it "exists within scope" do
            expect(@st.set_field("First name", "Eric", :within => 'person_form')).to be true
            expect(@st.set_field("First name", "Andrea", :within => 'spouse_form')).to be true
          end
        end

        context "text field with id" do
          it "exists" do
            expect(@st.set_field("first_name", "Eric")).to be true
            expect(@st.set_field("last_name", "Pierce")).to be true
            expect(@st.field_contains("first_name", "Eric")).to be true
            expect(@st.field_contains("last_name", "Pierce")).to be true
          end
        end

        context "textarea with label" do
          it "exists" do
            expect(@st.set_field("Life story", "Blah blah blah")).to be true
            expect(@st.set_field("Life story", "Jibber jabber")).to be true
            expect(@st.field_contains("Life story", "Jibber jabber")).to be true
          end
        end

        context "textarea with id" do
          it "exists" do
            expect(@st.set_field("biography", "Blah blah blah")).to be true
            expect(@st.set_field("biography", "Jibber jabber")).to be true
            expect(@st.field_contains("biography", "Jibber jabber")).to be true
          end
        end

        context "text field with name but duplicate id" do
          it "exists" do
            expect(@st.set_field("second_duplicate", "Jibber jabber")).to be true
            expect(@st.field_contains("first_duplicate", "")).to be true
            expect(@st.field_contains("second_duplicate", "Jibber jabber")).to be true
          end
        end

        it "clears a field" do
          expect(@st.field_contains("message", "Your message goes here")).to be true
          expect(@st.set_field("message","")).to be true
          expect(@st.field_contains("message", "")).to be true
        end
      end

      context "fails when" do
        it "no field with the given label or id exists" do
          expect(@st.set_field("Middle name", "Matthew")).to be false
          expect(@st.set_field("middle_name", "Matthew")).to be false
        end

        it "field exists, but not within scope" do
          expect(@st.set_field("Life story", "Long story",
                        :within => 'spouse_form')).to be false
        end

        it "field exists, but is read-only" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.set_field("First name", "Eric")).to be false
        end

        it "field exists but is hidden" do
          #pending "selenium-client thinks hidden fields are editable" do
            # FIXME: This test fails, because the selenium-client 'is_editable'
            # method returns true for hidden fields. Rsel should work around
            # this; hidden fields should not be editable.
            expect(@st.set_field("secret", "whisper")).to be false
          #end
        end
      end
    end # set_field with type_into_field

    context "#set_field with #field_contains" do
      context "passes when" do
        context "text field with label" do
          it "equals the text" do
            @st.set_field("First name", "Marcus")
            expect(@st.field_contains("First name", "Marcus")).to be true
          end

          it "contains the text" do
            @st.set_field("First name", "Marcus")
            expect(@st.field_contains("First name", "Marc")).to be true
          end
        end

        context "textarea with label" do
          it "contains the text" do
            @st.set_field("Life story", "Blah dee blah")
            expect(@st.field_contains("Life story", "blah")).to be true
          end
        end
      end

      context "fails when" do
        context "text field with label" do
          it "does not contain the text" do
            @st.set_field("First name", "Marcus")
            expect(@st.field_contains("First name", "Eric")).to be false
          end
        end

        context "textarea with label" do
          it "does not contain the text" do
            @st.set_field("Life story", "Blah dee blah")
            expect(@st.field_contains("Life story", "spam")).to be false
          end
        end
      end
    end # set_field with field_contains

    context "#set_field with #generic_field_equals" do
      context "passes when" do
        context "text field with label" do
          it "equals the text" do
            @st.set_field("First name", "Ken")
            expect(@st.generic_field_equals("First name", "Ken")).to be true
          end

          it "equals the text, and is within scope" do
            @st.set_field("First name", "Eric", :within => "person_form")
            @st.generic_field_equals("First name", "Eric", :within => "person_form")
          end
        end

        context "textarea with label" do
          it "equals the text" do
            @st.set_field("Life story", "Blah dee blah")
            expect(@st.generic_field_equals("Life story", "Blah dee blah")).to be true
          end

          it "equals the text, and is within scope" do
            @st.set_field("Life story", "Blah dee blah",
                          :within => "person_form")
            expect(@st.generic_field_equals("Life story", "Blah dee blah",
                             :within => "person_form")).to be true
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
            expect(@st.generic_field_equals("First name", "Marc")).to be false
          end
        end

        context "text field with id" do
          it "exactly equals the text, but is an unsupported type" do
            #pending "hidden fields should be unsupported" do
              # FIXME: This test fails, because generic_field_equals does
              # in fact allow inspecting the value of a hidden field.
              expect(@st.generic_field_equals("secret", "psst")).to be false
            #end
          end
        end

        context "textarea with label" do
          it "does not exist" do
            expect(@st.generic_field_equals("Third name", "Smith")).to be false
          end

          it "does not exactly equal the text" do
            @st.set_field("Life story", "Blah dee blah")
            expect(@st.generic_field_equals("Life story", "Blah dee")).to be false
          end

          it "exactly equals the text, but is not within scope" do
            @st.set_field("First name", "Eric", :within => "person_form")
            expect(@st.generic_field_equals("First name", "Eric", :within => "spouse_form")).to be false
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
      expect(@st.visit("/form")).to be true
    end

    context "#set_field with #enable_checkbox" do
      context "passes when" do
        context "checkbox with label" do
          it "exists" do
            expect(@st.set_field("I like cheese", "on")).to be true
            expect(@st.set_field("I like salami", "on")).to be true
            expect(@st.generic_field_equals("I like cheese", "on")).to be true
            expect(@st.generic_field_equals("I like salami", "on")).to be true
          end

          it "exists and is already checked" do
            expect(@st.set_field("I like cheese", "on")).to be true
            expect(@st.set_field("I like cheese", "on")).to be true
            expect(@st.generic_field_equals("I like cheese", "on")).to be true
          end

          it "exists within scope" do
            expect(@st.set_field("I like cheese", "on", :within => "cheese_checkbox")).to be true
            expect(@st.set_field("I like salami", "on", :within => "salami_checkbox")).to be true
            expect(@st.generic_field_equals("I like cheese", "on", :within => "cheese_checkbox")).to be true
            expect(@st.generic_field_equals("I like salami", "on", :within => "salami_checkbox")).to be true
          end

          it "exists in table row" do
            @st.visit("/table")
            expect(@st.set_field("Like", "on", :in_row => "Marcus")).to be true
            expect(@st.generic_field_equals("Like", "on", :in_row => "Marcus")).to be true
          end
        end

        context "checkbox with id=" do
          it "exists" do
            expect(@st.set_field("id=like_cheese", "on")).to be true
            expect(@st.generic_field_equals("id=like_cheese", "on")).to be true
          end
        end

        context "checkbox with xpath=" do
          it "exists" do
            expect(@st.set_field("xpath=//input[@id='like_cheese']", "on")).to be true
            expect(@st.generic_field_equals("xpath=//input[@id='like_cheese']", "on")).to be true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            expect(@st.set_field("I dislike bacon", "on")).to be false
            expect(@st.set_field("I like broccoli", "on")).to be false
          end

          it "exists, but not within scope" do
            expect(@st.set_field("I like cheese", "on", :within => "salami_checkbox")).to be false
            expect(@st.set_field("I like salami", "on", :within => "cheese_checkbox")).to be false
          end

          it "exists, but not in table row" do
            @st.visit("/table")
            expect(@st.set_field("Like", "on", :in_row => "Eric")).to be false
          end

          it "exists, but is read-only" do
            expect(@st.visit("/readonly_form")).to be true
            expect(@st.set_field("I like salami", "on")).to be false
          end
        end
      end
    end # set_field with enable_checkbox

    context "#set_field with #disable_checkbox" do
      context "passes when" do
        context "checkbox with label" do
          it "exists" do
            expect(@st.set_field("I like cheese", "off")).to be true
            expect(@st.set_field("I like salami", "off")).to be true
            expect(@st.generic_field_equals("I like cheese", "off")).to be true
            expect(@st.generic_field_equals("I like salami", "off")).to be true
          end

          it "exists and is already unchecked" do
            expect(@st.set_field("I like cheese", "off")).to be true
            expect(@st.set_field("I like cheese", "off")).to be true
            expect(@st.generic_field_equals("I like cheese", "off")).to be true
          end

          it "exists within scope" do
            expect(@st.set_field("I like cheese", "off", :within => "cheese_checkbox")).to be true
            expect(@st.set_field("I like salami", "off", :within => "preferences_form")).to be true
            expect(@st.generic_field_equals("I like cheese", "off", :within => "cheese_checkbox")).to be true
            expect(@st.generic_field_equals("I like salami", "off", :within => "preferences_form")).to be true
          end

          it "exists in table row" do
            @st.visit("/table")
            expect(@st.set_field("Like", "off", :in_row => "Marcus")).to be true
            expect(@st.generic_field_equals("Like", "off", :in_row => "Marcus")).to be true
          end
        end

        context "checkbox with id=" do
          it "exists" do
            expect(@st.set_field("id=like_cheese", "off")).to be true
            expect(@st.generic_field_equals("id=like_cheese", "off")).to be true
          end
        end

        context "checkbox with xpath=" do
          it "exists" do
            expect(@st.set_field("xpath=//input[@id='like_cheese']", "off")).to be true
            expect(@st.generic_field_equals("xpath=//input[@id='like_cheese']", "off")).to be true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            expect(@st.set_field("I dislike bacon", "off")).to be false
            expect(@st.set_field("I like broccoli", "off")).to be false
          end

          it "exists, but not within scope" do
            expect(@st.set_field("I like cheese", "off", :within => "salami_checkbox")).to be false
            expect(@st.set_field("I like salami", "off", :within => "cheese_checkbox")).to be false
          end

          it "exists, but not in table row" do
            @st.visit("/table")
            expect(@st.set_field("Like", "off", :in_row => "Eric")).to be false
          end

          it "exists, but is read-only" do
            expect(@st.visit("/readonly_form")).to be true
            expect(@st.set_field("I like cheese", "off")).to be false
          end
        end
      end
    end # set_field with disable_checkbox

    context "#set_field with #checkbox_is_enabled" do
      context "passes when" do
        context "checkbox with label" do
          it "exists and is checked" do
            expect(@st.set_field("I like cheese", "on")).to be true
            expect(@st.checkbox_is_enabled("I like cheese")).to be true
          end

          it "exists within scope and is checked" do
            expect(@st.set_field("I like cheese", "on", :within => "cheese_checkbox")).to be true
            expect(@st.checkbox_is_enabled("I like cheese", :within => "cheese_checkbox")).to be true
          end

          it "exists in table row and is checked" do
            @st.visit("/table")
            expect(@st.set_field("Like", "on", :in_row => "Ken")).to be true
            expect(@st.checkbox_is_enabled("Like", :in_row => "Ken")).to be true
          end

          it "exists and is checked, but read-only" do
            expect(@st.visit("/readonly_form")).to be true
            expect(@st.checkbox_is_enabled("I like cheese")).to be true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            expect(@st.checkbox_is_enabled("I dislike bacon")).to be false
          end

          it "exists but is unchecked" do
            expect(@st.set_field("I like cheese", "off")).to be true
            expect(@st.checkbox_is_enabled("I like cheese")).to be false
          end

          it "exists and is checked, but not within scope" do
            expect(@st.set_field("I like cheese", "on", :within => "cheese_checkbox")).to be true
            expect(@st.checkbox_is_enabled("I like cheese", :within => "salami_checkbox")).to be false
          end

          it "exists and is checked, but not in table row" do
            @st.visit("/table")
            expect(@st.set_field("Like", "on", :in_row => "Marcus")).to be true
            expect(@st.checkbox_is_enabled("Like", :in_row => "Eric")).to be false
          end
        end
      end
    end # set_field with checkbox_is_enabled

    context "#set_field with #checkbox_is_disabled" do
      context "passes when" do
        context "checkbox with label" do
          it "exists and is unchecked" do
            expect(@st.set_field("I like cheese", "off")).to be true
            expect(@st.checkbox_is_disabled("I like cheese")).to be true
          end

          it "exists within scope and is unchecked" do
            expect(@st.set_field("I like cheese", "off", :within => "cheese_checkbox")).to be true
            expect(@st.checkbox_is_disabled("I like cheese", :within => "cheese_checkbox")).to be true
          end

          it "exists in table row and is unchecked" do
            @st.visit("/table")
            expect(@st.set_field("Like", "off", :in_row => "Ken")).to be true
            expect(@st.checkbox_is_disabled("Like", :in_row => "Ken")).to be true
          end

          it "exists and is unchecked, but read-only" do
            expect(@st.visit("/readonly_form")).to be true
            expect(@st.checkbox_is_disabled("I like salami")).to be true
          end
        end
      end

      context "fails when" do
        context "checkbox with label" do
          it "does not exist" do
            expect(@st.checkbox_is_disabled("I dislike bacon")).to be false
          end

          it "exists but is checked" do
            expect(@st.set_field("I like cheese", "on")).to be true
            expect(@st.checkbox_is_disabled("I like cheese")).to be false
          end

          it "exists and is unchecked, but not within scope" do
            expect(@st.set_field("I like cheese", "off", :within => "cheese_checkbox")).to be true
            expect(@st.checkbox_is_disabled("I like cheese", :within => "salami_checkbox")).to be false
          end

          it "exists and is unchecked, but not in table row" do
            @st.visit("/table")
            expect(@st.set_field("Like", "off", :in_row => "Marcus")).to be true
            expect(@st.checkbox_is_disabled("Like", :in_row => "Eric")).to be false
          end
        end
      end
    end # set_field with checkbox_is_disabled
  end # checkboxes


  context "radiobuttons" do
    before(:each) do
      expect(@st.visit("/form")).to be true
    end

    context "#set_field with #select_radio" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists" do
            expect(@st.set_field("Briefs")).to be true
          end

          it "exists within scope" do
            expect(@st.set_field("Briefs", "", :within => "clothing")).to be true
          end

          it "exists in table row" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            expect(@st.set_field("Naked", "")).to be false
          end

          it "exists, but not within scope" do
            expect(@st.set_field("Briefs", "", :within => "food")).to be false
          end

          it "exists, but is read-only" do
            expect(@st.visit("/readonly_form")).to be true
            expect(@st.set_field("Boxers", "")).to be false
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
            @st.set_field("Briefs")
            expect(@st.radio_is_enabled("Briefs")).to be true
          end

          it "exists within scope, and is enabled" do
            @st.set_field("Briefs", "", :within => "clothing")
            expect(@st.radio_is_enabled("Briefs", :within => "clothing")).to be true
          end

          it "exists in table row, and is enabled" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            expect(@st.radio_is_enabled("Naked")).to be false
          end

          it "exists, but is not enabled" do
            @st.set_field("Briefs", "")
            expect(@st.radio_is_enabled("Boxers")).to be false
          end

          it "exists and is enabled, but not within scope" do
            @st.set_field("Briefs", "", :within => "clothing")
            expect(@st.radio_is_enabled("Briefs", :within => "food")).to be false
          end
        end
      end
    end # set_field with radio_is_enabled

    context "#set_field with #generic_field_equals for #radio_is_enabled" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists, and is enabled" do
            @st.set_field("Briefs")
            expect(@st.generic_field_equals("Briefs", "on")).to be true
          end

          it "exists within scope, and is enabled" do
            @st.set_field("Briefs", "", :within => "clothing")
            expect(@st.generic_field_equals("Briefs", "on", :within => "clothing")).to be true
          end

          it "exists in table row, and is enabled" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            expect(@st.generic_field_equals("Naked", "on")).to be false
          end

          it "exists, but is not enabled" do
            @st.set_field("Briefs", "")
            expect(@st.generic_field_equals("Boxers", "on")).to be false
          end

          it "exists and is enabled, but not within scope" do
            @st.set_field("Briefs", "", :within => "clothing")
            expect(@st.generic_field_equals("Briefs", "on", :within => "food")).to be false
          end
        end
      end
    end # set_field with generic_field_equals for radio_is_enabled

    context "#set_field with #generic_field_equals for #radio_is_disabled" do
      context "passes when" do
        context "radiobutton with label" do
          it "exists, and is disabled" do
            @st.set_field("Boxers")
            expect(@st.generic_field_equals("Briefs", "off")).to be true
          end

          it "exists within scope, and is disabled" do
            @st.set_field("Boxers", "", :within => "clothing")
            expect(@st.generic_field_equals("Briefs", "off", :within => "clothing")).to be true
          end

          it "exists in table row, and is enabled" do
            # TODO
          end
        end
      end

      context "fails when" do
        context "radiobutton with label" do
          it "does not exist" do
            expect(@st.generic_field_equals("Naked", "off")).to be false
          end

          it "exists, but is enabled" do
            @st.set_field("Briefs", "")
            expect(@st.generic_field_equals("Briefs", "off")).to be false
          end

          it "exists and is disabled, but not within scope" do
            @st.set_field("Boxers", "", :within => "clothing")
            expect(@st.generic_field_equals("Briefs", "off", :within => "food")).to be false
          end
        end
      end
    end # set_field with generic_field_equals for radio_is_disabled
  end # radiobuttons


  context "dropdowns" do
    before(:each) do
      expect(@st.visit("/form")).to be true
    end

    context "#set_field with #select_from_dropdown" do
      context "passes when" do
        it "option exists in the dropdown" do
          expect(@st.set_field("Height", "Tall")).to be true
          expect(@st.set_field("Weight", "Medium")).to be true
        end

        it "option exists in the dropdown within scope" do
          expect(@st.set_field("Height", "Tall", :within => "spouse_form")).to be true
        end

        it "option exists in the dropdown in table row" do
          @st.visit("/table")
          expect(@st.set_field("Gender", "Male", :in_row => "Eric")).to be true
        end
      end

      context "fails when" do
        it "no such dropdown exists" do
          expect(@st.set_field("Eggs", "Over easy")).to be false
        end

        it "dropdown exists, but the option doesn't" do
          expect(@st.set_field("Height", "Giant")).to be false
          expect(@st.set_field("Weight", "Obese")).to be false
        end

        it "dropdown exists, but is read-only" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.set_field("Height", "Tall")).to be false
        end

        it "dropdown exists, but not within scope" do
          expect(@st.set_field("Weight", "Medium", :within => "spouse_form")).to be false
        end

        it "dropdown exists, but not in table row" do
          @st.visit("/table")
          expect(@st.set_field("Gender", "Female", :in_row => "First name")).to be false
        end
      end
    end # set_field with select_from_dropdown

    context "#set_field with #dropdown_includes" do
      context "passes when" do
        it "option exists in the dropdown" do
          expect(@st.dropdown_includes("Height", "Tall")).to be true
          expect(@st.dropdown_includes("Weight", "Medium")).to be true
        end

        it "option exists in a read-only dropdown" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.dropdown_includes("Height", "Tall")).to be true
        end
      end

      context "fails when" do
        it "dropdown exists, but the option doesn't" do
          expect(@st.dropdown_includes("Height", "Giant")).to be false
          expect(@st.dropdown_includes("Weight", "Obese")).to be false
        end

        it "no such dropdown exists" do
          expect(@st.dropdown_includes("Eggs", "Over easy")).to be false
        end
      end
    end # set_field with dropdown_includes

    context "#set_field with #dropdown_equals" do
      context "passes when" do
        it "option is selected in the dropdown" do
          ["Short", "Average", "Tall"].each do |height|
            @st.set_field("Height", height)
            expect(@st.dropdown_equals("Height", height)).to be true
          end
        end

        it "option is selected in a read-only dropdown" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.dropdown_equals("Height", "Average")).to be true
        end

        it "option is selected in the dropdown, within scope" do
          ["Short", "Average", "Tall"].each do |height|
            @st.set_field("Height", height, :within => "spouse_form")
            expect(@st.dropdown_equals("Height", height, :within => "spouse_form")).to be true
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
          expect(@st.dropdown_equals("Eggs", "Over easy")).to be false
        end

        it "dropdown exists, but the option is not selected" do
          @st.set_field("Height", "Short")
          expect(@st.dropdown_equals("Height", "Average")).to be false
          expect(@st.dropdown_equals("Height", "Tall")).to be false

          @st.set_field("Height", "Average")
          expect(@st.dropdown_equals("Height", "Short")).to be false
          expect(@st.dropdown_equals("Height", "Tall")).to be false

          @st.set_field("Height", "Tall")
          expect(@st.dropdown_equals("Height", "Short")).to be false
          expect(@st.dropdown_equals("Height", "Average")).to be false
        end

        it "dropdown exists, and option is selected, but not within scope" do
          @st.set_field("Height", "Tall", :within => "person_form")
          @st.set_field("Height", "Short", :within => "spouse_form")
          expect(@st.dropdown_equals("Height", "Tall", :within => "spouse_form")).to be false
        end

        it "dropdown exists, and option is selected, but not in table row" do
          @st.visit("/table")
          @st.set_field("Gender", "Female", :in_row => "Eric")
          @st.set_field("Gender", "Male", :in_row => "Marcus")
          expect(@st.dropdown_equals("Gender", "Female", :in_row => "Marcus")).to be false
        end
      end
    end # set_field with dropdown_equals

    context "#set_field with #generic_field_equals for #dropdown_equals" do
      context "passes when" do
        it "option is selected in the dropdown" do
          ["Short", "Average", "Tall"].each do |height|
            @st.set_field("Height", height)
            expect(@st.generic_field_equals("Height", height)).to be true
          end
        end

        it "option is selected in a read-only dropdown" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.generic_field_equals("Height", "Average")).to be true
        end

        it "option is selected in the dropdown, within scope" do
          ["Short", "Average", "Tall"].each do |height|
            @st.set_field("Height", height, :within => "spouse_form")
            expect(@st.generic_field_equals("Height", height, :within => "spouse_form")).to be true
          end
        end

        it "option is selected in the dropdown, in table row" do
          @st.visit("/table")
          ["Male", "Female"].each do |gender|
            expect(@st.set_field("Gender", gender, :in_row => "Eric")).to be true
            @st.generic_field_equals("Gender", gender, :in_row => "Eric")
          end
        end
      end

      context "fails when" do
        it "no such dropdown exists" do
          expect(@st.generic_field_equals("Eggs", "Over easy")).to be false
        end

        it "dropdown exists, but the option is not selected" do
          @st.set_field("Height", "Short")
          expect(@st.generic_field_equals("Height", "Average")).to be false
          expect(@st.generic_field_equals("Height", "Tall")).to be false

          @st.set_field("Height", "Average")
          expect(@st.generic_field_equals("Height", "Short")).to be false
          expect(@st.generic_field_equals("Height", "Tall")).to be false

          @st.set_field("Height", "Tall")
          expect(@st.generic_field_equals("Height", "Short")).to be false
          expect(@st.generic_field_equals("Height", "Average")).to be false
        end

        it "dropdown exists, and option is selected, but not within scope" do
          expect(@st.set_field("Height", "Tall", :within => "person_form")).to be true
          expect(@st.set_field("Height", "Short", :within => "spouse_form")).to be true
          expect(@st.generic_field_equals("Height", "Tall", :within => "spouse_form")).to be false
        end

        it "dropdown exists, and option is selected, but not in table row" do
          @st.visit("/table")
          expect(@st.set_field("Gender", "Female", :in_row => "Eric")).to be true
          expect(@st.set_field("Gender", "Male", :in_row => "Marcus")).to be true
          expect(@st.generic_field_equals("Gender", "Female", :in_row => "Marcus")).to be false
        end
      end
    end # set_field with generic_field_equals for dropdown_equals
  end # dropdowns


  context "#set_field with button click" do
    before(:each) do
      expect(@st.visit("/form")).to be true
    end

    it "clicks a button" do
      expect(@st.set_field("Submit person form", "clicked")).to be true
      expect(@st.page_loads_in_seconds_or_less(10)).to be true
      expect(@st.see("We appreciate your feedback")).to be true
    end
  end

  context "#set_field with link click" do
    before(:each) do
      expect(@st.visit("/")).to be true
    end
    it "clicks a link" do
      expect(@st.set_field("About this site", "clicked")).to be true
      expect(@st.page_loads_in_seconds_or_less(10)).to be true
      expect(@st.see("This site is really cool.")).to be true
    end
  end

end # set_field


