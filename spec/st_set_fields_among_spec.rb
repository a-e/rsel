require_relative 'st_spec_helper'

describe "#set_fields_among" do
  before(:each) do
    expect(@st.visit("/form")).to be true
  end

  context "passes when" do
    context "text fields with labels" do
      it "sets one field" do
        expect(@st.set_fields_among({"First name" => "Marcus"})).to be true
        expect(@st.field_contains("First name", "Marcus")).to be true
      end

      it "sets one field with string ids" do
        expect(@st.set_fields_among({"First name" => "Marcus"}, "")).to be true
        expect(@st.field_contains("First name", "Marcus")).to be true
      end

      it "does nothing, but has ids" do
        expect(@st.set_fields_among("", {"First name" => "Marcus"})).to be true
      end

      it "sets several fields" do
        @st.set_fields_among({"First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot."})
        expect(@st.field_contains("First name", "Ken")).to be true
        expect(@st.field_contains("Last name", "Brazier")).to be true
        expect(@st.field_contains("Life story", "story: I get testy")).to be true
      end
    end
    context "text fields with labels in a hash" do
      it "sets one field from a hash" do
        expect(@st.set_fields_among({"Faust name" => "Marcus"}, {"Faust Name" => "First name", "LOST name" => "Last name"})).to be true
        expect(@st.field_contains("First name", "Marcus")).to be true
      end

      it "sets many fields, some from a hash" do
        @st.set_fields_among({"Faust\\;name" => "Ken", :Lost => "Brazier", "Life story" => "I get testy a lot."},
                             {"Faust\\;Name" => "First name", :LOST => "Last name"}).should be true
        expect(@st.field_contains("First name", "Ken")).to be true
        expect(@st.field_contains("Last name", "Brazier")).to be true
        expect(@st.field_contains("Life story", "testy")).to be true
      end
    end
    it "clears a field" do
      expect(@st.set_fields_among({"message" => ""},"")).to be true
      expect(@st.field_contains("message", "")).to be true
    end
  end

  context "fails when" do
    context "text fields with labels" do
      it "cant find the first field" do
        expect(@st.set_fields_among({"Faust name" => "Ken", "Last name" => "Brazier"})).to be false
      end

      it "cant find the last field" do
        expect(@st.set_fields_among({"First name" => "Ken", "Lost name" => "Brazier"})).to be false
      end
    end
    context "text fields with labels in a hash" do
      it "cant find the first field" do
        @st.set_fields_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                             {"Faust Name" => "Lost name", "Lost name" => "Last name"}).should be false
      end

      it "cant find the last field" do
        @st.set_fields_among({"Faust name" => "Ken", "Lost name" => "Brazier"},
                             {"Faust Name" => "First name", "Lost name" => "Faust name"}).should be false
      end
    end
  end
end # set_fields_among

