require 'spec/wt_spec_helper'

describe 'fields' do
  before(:each) do
    @wt.visit("/form").should be_true
  end

  describe "#type_into_field" do
    context "passes when" do
      context "text field with label" do
        it "exists" do
          @wt.type_into_field("Eric", "First name").should be_true
          @wt.fill_in_with("Last name", "Pierce").should be_true
        end
        it "exists within scope" do
          @wt.type_into_field("Eric", "First name", :within => 'person_form').should be_true
          @wt.type_into_field("Andrea", "First name", :within => 'spouse_form').should be_true
        end
      end

      context "text field with id" do
        it "exists" do
          @wt.type_into_field("Eric", "first_name").should be_true
          @wt.fill_in_with("last_name", "Pierce").should be_true
        end
      end

      context "textarea with label" do
        it "exists" do
          @wt.type_into_field("Blah blah blah", "Life story").should be_true
          @wt.fill_in_with("Life story", "Jibber jabber").should be_true
        end
      end

      context "textarea with id" do
        it "exists" do
          @wt.type_into_field("Blah blah blah", "biography").should be_true
          @wt.fill_in_with("biography", "Jibber jabber").should be_true
        end
      end
    end

    context "fails when" do
      it "no field with the given label or id exists" do
        @wt.type_into_field("Matthew", "Middle name").should be_false
        @wt.fill_in_with("middle_name", "Matthew").should be_false
      end

      it "field exists, but not within scope" do
        @wt.type_into_field("Long story", "Life story",
                            :within => 'spouse_form').should be_false
      end

      it "field exists, but is read-only" do
        @wt.visit("/readonly_form").should be_true
        @wt.type_into_field("Eric", "First name").should be_false
      end
    end
  end

  describe "#field_contains" do
    context "passes when" do
      context "text field with label" do
        it "equals the text" do
          @wt.fill_in_with("First name", "Marcus")
          @wt.field_contains("First name", "Marcus").should be_true
        end

        it "contains the text" do
          @wt.fill_in_with("First name", "Marcus")
          @wt.field_contains("First name", "Marc").should be_true
        end
      end

      context "textarea with label" do
        it "contains the text" do
          @wt.fill_in_with("Life story", "Blah dee blah")
          @wt.field_contains("Life story", "blah").should be_true
        end
      end
    end

    context "fails when" do
      context "text field with label" do
        it "does not exist" do
          @wt.field_contains("Third name", "Smith").should be_false
        end

        it "does not contain the text" do
          @wt.fill_in_with("First name", "Marcus")
          @wt.field_contains("First name", "Eric").should be_false
        end
      end

      context "textarea with label" do
        it "does not contain the text" do
          @wt.fill_in_with("Life story", "Blah dee blah")
          @wt.field_contains("Life story", "spam").should be_false
        end
      end
    end
  end

  describe "#field_equals" do
    context "passes when" do
      context "text field with label" do
        it "equals the text" do
          @wt.fill_in_with("First name", "Ken")
          @wt.field_equals("First name", "Ken").should be_true
        end

        it "equals the text, and is within scope" do
          @wt.fill_in_with("First name", "Eric", :within => "person_form")
          @wt.field_equals("First name", "Eric", :within => "person_form")
        end
      end

      context "textarea with label" do
        it "equals the text" do
          @wt.fill_in_with("Life story", "Blah dee blah")
          @wt.field_equals("Life story", "Blah dee blah").should be_true
        end

        it "equals the text, and is within scope" do
          @wt.fill_in_with("Life story", "Blah dee blah",
                           :within => "person_form")
          @wt.field_equals("Life story", "Blah dee blah",
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
          @wt.fill_in_with("First name", "Marcus")
          @wt.field_equals("First name", "Marc").should be_false
        end
      end

      context "textarea with label" do
        it "does not exist" do
          @wt.field_equals("Third name", "Smith").should be_false
        end

        it "does not exactly equal the text" do
          @wt.fill_in_with("Life story", "Blah dee blah")
          @wt.field_equals("Life story", "Blah dee").should be_false
        end

        it "exactly equals the text, but is not within scope" do
          @wt.fill_in_with("First name", "Eric", :within => "person_form")
          @wt.field_equals("First name", "Eric", :within => "spouse_form").should be_false
        end

        it "exactly equals the text, but is not in table row" do
          # TODO
        end
      end
    end
  end

end
