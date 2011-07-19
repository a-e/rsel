require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest, 'text field' do
  before(:each) do
    @st.visit('/form').should be_true
  end

  context "type into or fill in" do
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
    end

    context "fails when" do
      it "no field with the given label or id exists" do
        @st.type_into_field("Matthew", "Middle name").should be_false
        @st.fill_in_with("middle_name", "Matthew").should be_false
      end
    end
  end

  context "should contain" do
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

  context "should equal" do
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

