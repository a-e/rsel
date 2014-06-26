require_relative 'st_spec_helper'

describe "#set_fields" do
  context "without studying" do
    before(:each) do
      expect(@st.visit("/form")).to be true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          expect(@st.set_fields("First name" => "Marcus")).to be true
          expect(@st.field_contains("First name", "Marcus")).to be true
        end

        it "sets zero fields" do
          expect(@st.set_fields("")).to be true
        end

        it "sets several fields" do
          expect(@st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.")).to be true
          expect(@st.field_contains("First name", "Ken")).to be true
          expect(@st.field_contains("Last name", "Brazier")).to be true
          expect(@st.field_contains("Life story", "story: I get testy")).to be true
        end

        it "clears a field" do
          expect(@st.set_fields("message" => "")).to be true
          expect(@st.field_contains("message", "")).to be true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          expect(@st.set_fields("Faust name" => "Ken", "Last name" => "Brazier")).to be false
        end

        it "cant find the last field" do
          expect(@st.set_fields("First name" => "Ken", "Lost name" => "Brazier")).to be false
        end
      end
    end
  end # set_fields


  context "with studying" do
    before(:all) do
      @st.set_fields_study_min('always')
    end
    before(:each) do
      expect(@st.visit("/form")).to be true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          expect(@st.set_fields("First name" => "Marcus")).to be true
          expect(@st.field_contains("First name", "Marcus")).to be true
        end

        it "sets zero fields" do
          expect(@st.set_fields("")).to be true
        end

        it "sets several fields" do
          expect(@st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.")).to be true
          expect(@st.field_contains("First name", "Ken")).to be true
          expect(@st.field_contains("Last name", "Brazier")).to be true
          expect(@st.field_contains("Life story", "story: I get testy")).to be true
        end

        it "clears a field" do
          expect(@st.set_fields("message" => "")).to be true
          expect(@st.field_contains("message", "")).to be true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          expect(@st.set_fields("Faust name" => "Ken", "Last name" => "Brazier")).to be false
        end

        it "cant find the last field" do
          expect(@st.set_fields("First name" => "Ken", "Lost name" => "Brazier")).to be false
        end
      end
    end
    after(:all) do
      @st.set_fields_study_min('default')
    end
  end
end # set_fields

