require_relative 'st_spec_helper'

describe "#set_fields" do
  context "without studying" do
    before(:each) do
      @st.visit("/form").should be true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          @st.set_fields("First name" => "Marcus").should be true
          @st.field_contains("First name", "Marcus").should be true
        end

        it "sets zero fields" do
          @st.set_fields("").should be true
        end

        it "sets several fields" do
          @st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be true
          @st.field_contains("First name", "Ken").should be true
          @st.field_contains("Last name", "Brazier").should be true
          @st.field_contains("Life story", "story: I get testy").should be true
        end

        it "clears a field" do
          @st.set_fields("message" => "").should be true
          @st.field_contains("message", "").should be true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          @st.set_fields("Faust name" => "Ken", "Last name" => "Brazier").should be false
        end

        it "cant find the last field" do
          @st.set_fields("First name" => "Ken", "Lost name" => "Brazier").should be false
        end
      end
    end
  end # set_fields


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
          @st.field_contains("First name", "Marcus").should be true
        end

        it "sets zero fields" do
          @st.set_fields("").should be true
        end

        it "sets several fields" do
          @st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be true
          @st.field_contains("First name", "Ken").should be true
          @st.field_contains("Last name", "Brazier").should be true
          @st.field_contains("Life story", "story: I get testy").should be true
        end

        it "clears a field" do
          @st.set_fields("message" => "").should be true
          @st.field_contains("message", "").should be true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          @st.set_fields("Faust name" => "Ken", "Last name" => "Brazier").should be false
        end

        it "cant find the last field" do
          @st.set_fields("First name" => "Ken", "Lost name" => "Brazier").should be false
        end
      end
    end
    after(:all) do
      @st.set_fields_study_min('default')
    end
  end
end # set_fields

