require_relative 'st_spec_helper'

describe 'fields' do
  before(:each) do
    @st.visit("/form").should be true
  end

  describe "#type_into_field" do
    context "passes when" do
      context "text field with label" do
        it "exists" do
          @st.type_into_field("Eric", "First name").should be true
          @st.fill_in_with("Last name", "Pierce").should be true
        end
        it "exists within scope" do
          @st.type_into_field("Eric", "First name", :within => 'person_form').should be true
          @st.type_into_field("Andrea", "First name", :within => 'spouse_form').should be true
        end
      end

      context "text field with id" do
        it "exists" do
          @st.type_into_field("Eric", "first_name").should be true
          @st.fill_in_with("last_name", "Pierce").should be true
        end
      end

      context "textarea with label" do
        it "exists" do
          @st.type_into_field("Blah blah blah", "Life story").should be true
          @st.fill_in_with("Life story", "Jibber jabber").should be true
        end
      end

      context "textarea with id" do
        it "exists" do
          @st.type_into_field("Blah blah blah", "biography").should be true
          @st.fill_in_with("biography", "Jibber jabber").should be true
        end
      end
    end

    context "fails when" do
      it "no field with the given label or id exists" do
        @st.type_into_field("Matthew", "Middle name").should be false
        @st.fill_in_with("middle_name", "Matthew").should be false
      end

      it "field exists, but not within scope" do
        @st.type_into_field("Long story", "Life story",
                            :within => 'spouse_form').should be false
      end

      it "field exists, but is read-only" do
        @st.visit("/readonly_form").should be true
        @st.type_into_field("Eric", "First name").should be false
      end
    end
  end

  describe "#field_contains" do
    context "passes when" do
      context "text field with label" do
        it "equals the text" do
          @st.fill_in_with("First name", "Marcus")
          @st.field_contains("First name", "Marcus").should be true
        end

        it "contains the text" do
          @st.fill_in_with("First name", "Marcus")
          @st.field_contains("First name", "Marc").should be true
        end
      end

      context "textarea with label" do
        it "contains the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_contains("Life story", "blah").should be true
        end
      end
    end

    context "fails when" do
      context "text field with label" do
        it "does not exist" do
          @st.field_contains("Third name", "Smith").should be false
        end

        it "does not contain the text" do
          @st.fill_in_with("First name", "Marcus")
          @st.field_contains("First name", "Eric").should be false
        end
      end

      context "textarea with label" do
        it "does not contain the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_contains("Life story", "spam").should be false
        end
      end
    end
  end

  describe "#field_equals" do
    context "passes when" do
      context "text field with label" do
        it "equals the text" do
          @st.fill_in_with("First name", "Ken")
          @st.field_equals("First name", "Ken").should be true
        end

        it "equals the text, and is within scope" do
          @st.fill_in_with("First name", "Eric", :within => "person_form")
          @st.field_equals("First name", "Eric", :within => "person_form")
        end
      end

      context "textarea with label" do
        it "equals the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_equals("Life story", "Blah dee blah").should be true
        end

        it "equals the text, and is within scope" do
          @st.fill_in_with("Life story", "Blah dee blah",
                           :within => "person_form")
          @st.field_equals("Life story", "Blah dee blah",
                           :within => "person_form").should be true
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
          @st.field_equals("First name", "Marc").should be false
        end
      end

      context "textarea with label" do
        it "does not exist" do
          @st.field_equals("Third name", "Smith").should be false
        end

        it "does not exactly equal the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_equals("Life story", "Blah dee").should be false
        end

        it "exactly equals the text, but is not within scope" do
          @st.fill_in_with("First name", "Eric", :within => "person_form")
          @st.field_equals("First name", "Eric", :within => "spouse_form").should be false
        end

        it "exactly equals the text, but is not in table row" do
          # TODO
        end
      end
    end
  end

end
