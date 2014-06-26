require_relative 'st_spec_helper'

describe 'fields' do
  before(:each) do
    expect(@st.visit("/form")).to be true
  end

  describe "#type_into_field" do
    context "passes when" do
      context "text field with label" do
        it "exists" do
          expect(@st.type_into_field("Eric", "First name")).to be true
          expect(@st.fill_in_with("Last name", "Pierce")).to be true
        end
        it "exists within scope" do
          expect(@st.type_into_field("Eric", "First name", :within => 'person_form')).to be true
          expect(@st.type_into_field("Andrea", "First name", :within => 'spouse_form')).to be true
        end
      end

      context "text field with id" do
        it "exists" do
          expect(@st.type_into_field("Eric", "first_name")).to be true
          expect(@st.fill_in_with("last_name", "Pierce")).to be true
        end
      end

      context "textarea with label" do
        it "exists" do
          expect(@st.type_into_field("Blah blah blah", "Life story")).to be true
          expect(@st.fill_in_with("Life story", "Jibber jabber")).to be true
        end
      end

      context "textarea with id" do
        it "exists" do
          expect(@st.type_into_field("Blah blah blah", "biography")).to be true
          expect(@st.fill_in_with("biography", "Jibber jabber")).to be true
        end
      end
    end

    context "fails when" do
      it "no field with the given label or id exists" do
        expect(@st.type_into_field("Matthew", "Middle name")).to be false
        expect(@st.fill_in_with("middle_name", "Matthew")).to be false
      end

      it "field exists, but not within scope" do
        expect(@st.type_into_field("Long story", "Life story",
                            :within => 'spouse_form')).to be false
      end

      it "field exists, but is read-only" do
        expect(@st.visit("/readonly_form")).to be true
        expect(@st.type_into_field("Eric", "First name")).to be false
      end
    end
  end

  describe "#field_contains" do
    context "passes when" do
      context "text field with label" do
        it "equals the text" do
          @st.fill_in_with("First name", "Marcus")
          expect(@st.field_contains("First name", "Marcus")).to be true
        end

        it "contains the text" do
          @st.fill_in_with("First name", "Marcus")
          expect(@st.field_contains("First name", "Marc")).to be true
        end
      end

      context "textarea with label" do
        it "contains the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          expect(@st.field_contains("Life story", "blah")).to be true
        end
      end
    end

    context "fails when" do
      context "text field with label" do
        it "does not exist" do
          expect(@st.field_contains("Third name", "Smith")).to be false
        end

        it "does not contain the text" do
          @st.fill_in_with("First name", "Marcus")
          expect(@st.field_contains("First name", "Eric")).to be false
        end
      end

      context "textarea with label" do
        it "does not contain the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          expect(@st.field_contains("Life story", "spam")).to be false
        end
      end
    end
  end

  describe "#field_equals" do
    context "passes when" do
      context "text field with label" do
        it "equals the text" do
          @st.fill_in_with("First name", "Ken")
          expect(@st.field_equals("First name", "Ken")).to be true
        end

        it "equals the text, and is within scope" do
          @st.fill_in_with("First name", "Eric", :within => "person_form")
          @st.field_equals("First name", "Eric", :within => "person_form")
        end
      end

      context "textarea with label" do
        it "equals the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          expect(@st.field_equals("Life story", "Blah dee blah")).to be true
        end

        it "equals the text, and is within scope" do
          @st.fill_in_with("Life story", "Blah dee blah",
                           :within => "person_form")
          expect(@st.field_equals("Life story", "Blah dee blah",
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
          @st.fill_in_with("First name", "Marcus")
          expect(@st.field_equals("First name", "Marc")).to be false
        end
      end

      context "textarea with label" do
        it "does not exist" do
          expect(@st.field_equals("Third name", "Smith")).to be false
        end

        it "does not exactly equal the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          expect(@st.field_equals("Life story", "Blah dee")).to be false
        end

        it "exactly equals the text, but is not within scope" do
          @st.fill_in_with("First name", "Eric", :within => "person_form")
          expect(@st.field_equals("First name", "Eric", :within => "spouse_form")).to be false
        end

        it "exactly equals the text, but is not in table row" do
          # TODO
        end
      end
    end
  end

end
