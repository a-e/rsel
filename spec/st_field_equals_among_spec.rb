require_relative 'st_spec_helper'

describe "#field_equals_among" do
  before(:each) do
    expect(@st.visit("/form")).to be true
  end

  context "passes when" do
    context "text field with label" do
      it "equals the page text" do
        expect(@st.set_field_among("First name", "Marcus", "Last name" => "nowhere")).to be true
        expect(@st.field_equals_among("First name", "Marcus", "Last name" => "nowhere")).to be true
      end

      it "equals the page text and has no ids" do
        expect(@st.set_field_among("First name", "Marcus", "")).to be true
        expect(@st.field_equals_among("First name", "Marcus", "")).to be true
      end

      it "equals the hash text" do
        expect(@st.set_field_among("Last name", "Marcus", "Last name" => "First name")).to be true
        expect(@st.field_equals_among("Last name", "Marcus", "Last name" => "First name")).to be true
      end

      it "equals the escaped hash text" do
        expect(@st.set_field_among("Last:name", "Marcus", "Last\\;name" => "First name")).to be true
        expect(@st.field_equals_among("Last:name", "Marcus", "Last\\;name" => "First name")).to be true
      end
    end
  end

  context "fails when" do
    context "text field with label" do
      it "does not exist" do
        expect(@st.field_equals_among("Third name", "")).to be false
      end

      it "has a hash value that does not exist" do
        expect(@st.field_equals_among("Last name", "", "Last name" => "Third name")).to be false
      end

      it "does not equal the expected text" do
        expect(@st.field_equals_among("Last name", "Marcus", "Last name" => "First name")).to be false
      end
    end
  end
end # field_equals_among

