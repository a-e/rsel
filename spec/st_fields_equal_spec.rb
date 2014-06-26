require_relative 'st_spec_helper'

describe "#fields_equal" do
  context "without studying" do
    before(:each) do
      expect(@st.visit("/form")).to be true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          expect(@st.set_fields("First name" => "Marcus")).to be true
          expect(@st.fields_equal("First name" => "Marcus")).to be true
        end

        it "sets zero fields" do
          expect(@st.fields_equal("")).to be true
        end

        it "sets several fields" do
          expect(@st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.")).to be true
          expect(@st.fields_equal("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.")).to be true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          expect(@st.fields_equal("Faust name" => "", "Last name" => "")).to be false
        end

        it "cant find the last field" do
          expect(@st.fields_equal("First name" => "", "Lost name" => "")).to be false
        end

        it "fields are not equal" do
          expect(@st.fields_equal("First name" => "Ken", "Last name" => "Brazier")).to be false
        end
      end
    end
  end

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
          expect(@st.fields_equal("First name" => "Marcus")).to be true
        end

        it "sets zero fields" do
          expect(@st.fields_equal("")).to be true
        end

        it "sets several fields" do
          expect(@st.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.")).to be true
          expect(@st.fields_equal("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.")).to be true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          expect(@st.fields_equal("Faust name" => "", "Last name" => "")).to be false
        end

        it "cant find the last field" do
          expect(@st.fields_equal("First name" => "", "Lost name" => "")).to be false
        end

        it "fields are not equal" do
          expect(@st.fields_equal("First name" => "Ken", "Last name" => "Brazier")).to be false
        end
      end
    end
    after(:all) do
      @st.set_fields_study_min('default')
    end
  end
end # fields_equal

