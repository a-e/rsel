require 'spec/spec_helper'

describe "#set_fields" do
  before(:each) do
    @st.visit("/form").should be_true
  end

  context "passes when" do
    context "text fields with labels" do
      it "sets one field" do
        @st.set_fields("First name" => "Marcus").should be_true
        @st.field_contains("First name", "Marcus").should be_true
      end

      it "sets zero fields" do
        @st.set_fields("").should be_true
      end

      it "sets several fields" do
        @st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
        @st.field_contains("First name", "Ken").should be_true
        @st.field_contains("Last name", "Brazier").should be_true
        @st.field_contains("Life story", "story: I get testy").should be_true
      end
    end
  end

  context "fails when" do
    context "text fields with labels" do
      it "cant find the first field" do
        @st.set_fields("Faust name" => "Ken", "Last name" => "Brazier").should be_false
      end

      it "cant find the last field" do
        @st.set_fields("First name" => "Ken", "Lost name" => "Brazier").should be_false
      end
    end
  end
end # set_fields


