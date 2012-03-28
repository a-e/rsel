require 'spec/wt_spec_helper'

describe "#set_fields_among" do
  before(:each) do
    @wt.visit("/form").should be_true
  end

  context "passes when" do
    context "text fields with labels" do
      it "sets one field" do
        @wt.set_fields_among({"First name" => "Marcus"}).should be_true
        @wt.field_contains("First name", "Marcus").should be_true
      end

      it "sets one field with string ids" do
        @wt.set_fields_among({"First name" => "Marcus"}, "").should be_true
        @wt.field_contains("First name", "Marcus").should be_true
      end

      it "does nothing, but has ids" do
        @wt.set_fields_among("", {"First name" => "Marcus"}).should be_true
      end

      it "sets several fields" do
        @wt.set_fields_among({"First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot."})
        @wt.field_contains("First name", "Ken").should be_true
        @wt.field_contains("Last name", "Brazier").should be_true
        @wt.field_contains("Life story", "story: I get testy").should be_true
      end
    end
    context "text fields with labels in a hash" do
      it "sets one field from a hash" do
        @wt.set_fields_among({"Faust name" => "Marcus"}, {"Faust Name" => "First name", "LOST name" => "Last name"}).should be_true
        @wt.field_contains("First name", "Marcus").should be_true
      end

      it "sets many fields, some from a hash" do
        @wt.set_fields_among({"Faust\\;name" => "Ken", :Lost => "Brazier", "Life story" => "I get testy a lot."},
                             {"Faust\\;Name" => "First name", :LOST => "Last name"}).should be_true
        @wt.field_contains("First name", "Ken").should be_true
        @wt.field_contains("Last name", "Brazier").should be_true
        @wt.field_contains("Life story", "testy").should be_true
      end
    end
    it "clears a field" do
      @wt.set_fields_among({"message" => ""},"").should be_true
      @wt.field_contains("message", "").should be_true
    end
  end

  context "fails when" do
    context "text fields with labels" do
      it "cant find the first field" do
        @wt.set_fields_among({"Faust name" => "Ken", "Last name" => "Brazier"}).should be_false
      end

      it "cant find the last field" do
        @wt.set_fields_among({"First name" => "Ken", "Lost name" => "Brazier"}).should be_false
      end
    end
    context "text fields with labels in a hash" do
      it "cant find the first field" do
        @wt.set_fields_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                             {"Faust Name" => "Lost name", "Lost name" => "Last name"}).should be_false
      end

      it "cant find the last field" do
        @wt.set_fields_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                             {"Faust Name" => "First name", "Lost name" => "Faust name"}).should be_false
      end
    end
  end
end # set_fields_among

