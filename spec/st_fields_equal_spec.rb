require 'spec/st_spec_helper'

describe "#fields_equal" do
  before(:each) do
    @st.visit("/form").should be_true
  end

  context "passes when" do
    context "text fields with labels" do
      it "sets one field" do
        @st.set_fields("First name" => "Marcus").should be_true
        @st.fields_equal("First name" => "Marcus").should be_true
      end

      it "sets zero fields" do
        @st.fields_equal("").should be_true
      end

      it "sets several fields" do
        @st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
        @st.fields_equal("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
      end
    end
  end

  context "fails when" do
    context "text fields with labels" do
      it "cant find the first field" do
        @st.fields_equal("Faust name" => "", "Last name" => "").should be_false
      end

      it "cant find the last field" do
        @st.fields_equal("First name" => "", "Lost name" => "").should be_false
      end

      it "fields are not equal" do
        @st.fields_equal("First name" => "Ken", "Last name" => "Brazier").should be_false
      end
    end
  end
end # fields_equal


