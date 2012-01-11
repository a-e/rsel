require 'spec/spec_helper'

describe "#set_fields_among" do
  before(:each) do
    @st.visit("/form").should be_true
  end

  context "passes when" do
    context "text fields with labels" do
      it "sets one field" do
        @st.set_fields_among({"First name" => "Marcus"}).should be_true
        @st.field_contains("First name", "Marcus").should be_true
      end

      it "sets one field with string ids" do
        @st.set_fields_among({"First name" => "Marcus"}, "").should be_true
        @st.field_contains("First name", "Marcus").should be_true
      end

      it "does nothing, but has ids" do
        @st.set_fields_among("", {"First name" => "Marcus"}).should be_true
      end

      it "sets several fields" do
        @st.set_fields_among({"First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot."})
        @st.field_contains("First name", "Ken").should be_true
        @st.field_contains("Last name", "Brazier").should be_true
        @st.field_contains("Life story", "story: I get testy").should be_true
      end
    end
    context "text fields with labels in a hash" do
      it "sets one field from a hash" do
        @st.set_fields_among({"Faust name" => "Marcus"}, {"Faust Name" => "First name", "LOST name" => "Last name"}).should be_true
        @st.field_contains("First name", "Marcus").should be_true
      end

      it "sets many fields, some from a hash" do
        @st.set_fields_among({"Faust\\;name" => "Ken", :Lost => "Brazier", "Life story" => "I get testy a lot."},
                             {"Faust\\;Name" => "First name", :LOST => "Last name"}).should be_true
        @st.field_contains("First name", "Ken").should be_true
        @st.field_contains("Last name", "Brazier").should be_true
        @st.field_contains("Life story", "testy").should be_true
      end
    end
  end

  context "fails when" do
    context "text fields with labels" do
      it "cant find the first field" do
        @st.set_fields_among({"Faust name" => "Ken", "Last name" => "Brazier"}).should be_false
      end

      it "cant find the last field" do
        @st.set_fields_among({"First name" => "Ken", "Lost name" => "Brazier"}).should be_false
      end
    end
    context "text fields with labels in a hash" do
      it "cant find the first field" do
        @st.set_fields_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                             {"Faust Name" => "Lost name", "Lost name" => "Last name"}).should be_false
      end

      it "cant find the last field" do
        @st.set_fields_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                             {"Faust Name" => "First name", "Lost name" => "Faust name"}).should be_false
      end
    end
  end
end # set_fields_among

