require_relative 'st_spec_helper'

describe "#field_equals_among" do
  before(:each) do
    @st.visit("/form").should be true
  end

  context "passes when" do
    context "text field with label" do
      it "equals the page text" do
        @st.set_field_among("First name", "Marcus", "Last name" => "nowhere").should be true
        @st.field_equals_among("First name", "Marcus", "Last name" => "nowhere").should be true
      end

      it "equals the page text and has no ids" do
        @st.set_field_among("First name", "Marcus", "").should be true
        @st.field_equals_among("First name", "Marcus", "").should be true
      end

      it "equals the hash text" do
        @st.set_field_among("Last name", "Marcus", "Last name" => "First name").should be true
        @st.field_equals_among("Last name", "Marcus", "Last name" => "First name").should be true
      end

      it "equals the escaped hash text" do
        @st.set_field_among("Last:name", "Marcus", "Last\\;name" => "First name").should be true
        @st.field_equals_among("Last:name", "Marcus", "Last\\;name" => "First name").should be true
      end
    end
  end

  context "fails when" do
    context "text field with label" do
      it "does not exist" do
        @st.field_equals_among("Third name", "").should be false
      end

      it "has a hash value that does not exist" do
        @st.field_equals_among("Last name", "", "Last name" => "Third name").should be false
      end

      it "does not equal the expected text" do
        @st.field_equals_among("Last name", "Marcus", "Last name" => "First name").should be false
      end
    end
  end
end # field_equals_among

