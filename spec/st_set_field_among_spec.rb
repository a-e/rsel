require 'spec/spec_helper'

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

