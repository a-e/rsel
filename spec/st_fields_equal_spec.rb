require_relative 'st_spec_helper'

describe "#fields_equal" do
  context "without studying" do
    before(:each) do
      @st.visit("/form").should be true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          @st.set_fields("First name" => "Marcus").should be true
          @st.fields_equal("First name" => "Marcus").should be true
        end

        it "sets zero fields" do
          @st.fields_equal("").should be true
        end

        it "sets several fields" do
          @st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be true
          @st.fields_equal("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          @st.fields_equal("Faust name" => "", "Last name" => "").should be false
        end

        it "cant find the last field" do
          @st.fields_equal("First name" => "", "Lost name" => "").should be false
        end

        it "fields are not equal" do
          @st.fields_equal("First name" => "Ken", "Last name" => "Brazier").should be false
        end
      end
    end
  end

  context "with studying" do
    before(:all) do
      @st.set_fields_study_min('always')
    end
    before(:each) do
      @st.visit("/form").should be true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          @st.set_fields("First name" => "Marcus").should be true
          @st.fields_equal("First name" => "Marcus").should be true
        end

        it "sets zero fields" do
          @st.fields_equal("").should be true
        end

        it "sets several fields" do
          @st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be true
          @st.fields_equal("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          @st.fields_equal("Faust name" => "", "Last name" => "").should be false
        end

        it "cant find the last field" do
          @st.fields_equal("First name" => "", "Lost name" => "").should be false
        end

        it "fields are not equal" do
          @st.fields_equal("First name" => "Ken", "Last name" => "Brazier").should be false
        end
      end
    end
    after(:all) do
      @st.set_fields_study_min('default')
    end
  end
end # fields_equal

