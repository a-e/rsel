require_relative 'wt_spec_helper'

describe "#fields_equal" do
  context "without studying" do
    before(:each) do
      @wt.visit("/form").should be_true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          @wt.set_fields("First name" => "Marcus").should be_true
          @wt.fields_equal("First name" => "Marcus").should be_true
        end

        it "sets zero fields" do
          @wt.fields_equal("").should be_true
        end

        it "sets several fields" do
          @wt.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
          @wt.fields_equal("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          @wt.fields_equal("Faust name" => "", "Last name" => "").should be_false
        end

        it "cant find the last field" do
          @wt.fields_equal("First name" => "", "Lost name" => "").should be_false
        end

        it "fields are not equal" do
          @wt.fields_equal("First name" => "Ken", "Last name" => "Brazier").should be_false
        end
      end
    end
  end

  context "with studying" do
    before(:all) do
      @wt.set_fields_study_min('always')
    end
    before(:each) do
      @wt.visit("/form").should be_true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          @wt.set_fields("First name" => "Marcus").should be_true
          @wt.fields_equal("First name" => "Marcus").should be_true
        end

        it "sets zero fields" do
          @wt.fields_equal("").should be_true
        end

        it "sets several fields" do
          @wt.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
          @wt.fields_equal("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          @wt.fields_equal("Faust name" => "", "Last name" => "").should be_false
        end

        it "cant find the last field" do
          @wt.fields_equal("First name" => "", "Lost name" => "").should be_false
        end

        it "fields are not equal" do
          @wt.fields_equal("First name" => "Ken", "Last name" => "Brazier").should be_false
        end
      end
    end
    after(:all) do
      @wt.set_fields_study_min('default')
    end
  end
end # fields_equal

