require_relative 'st_spec_helper'

# TODO: Add test cases with scopes to the next three functions described.
describe "#set_field_among" do
  before(:each) do
    expect(@st.visit("/form")).to be true
  end

  context "passes when" do
    context "text field with label" do
      it "equals the page text" do
        expect(@st.set_field_among("First name", "Marcus", "Last name" => "nowhere")).to be true
        expect(@st.field_contains("First name", "Marcus")).to be true
      end

      it "equals the page text and has no ids" do
        expect(@st.set_field_among("First name", "Marcus", "")).to be true
        expect(@st.field_contains("First name", "Marcus")).to be true
      end

      it "equals the hash text" do
        expect(@st.set_field_among("Last name", "Marcus", "Last name" => "First name")).to be true
        expect(@st.field_contains("First name", "Marcus")).to be true
      end

      it "equals the escaped hash text" do
        expect(@st.set_field_among("Last:name", "Marcus", "Last\\;name" => "First name")).to be true
        expect(@st.field_contains("First name", "Marcus")).to be true
      end
    end
  end

  context "fails when" do
    context "text field with label" do
      it "does not exist" do
        expect(@st.set_field_among("Third name", "Smith")).to be false
      end

      it "has a hash value that does not exist" do
        expect(@st.set_field_among("Last name", "Smith", "Last name" => "Third name")).to be false
      end
    end
  end
end # set_field_among

