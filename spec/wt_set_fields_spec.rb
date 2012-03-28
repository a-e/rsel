require 'spec/wt_spec_helper'

describe "#set_fields" do
  context "without studying" do
    before(:each) do
      @wt.visit("/form").should be_true
    end

    context "passes when" do
      context "text fields with labels" do
        it "sets one field" do
          @wt.set_fields("First name" => "Marcus").should be_true
          @wt.field_contains("First name", "Marcus").should be_true
        end

        it "sets zero fields" do
          @wt.set_fields("").should be_true
        end

        it "sets several fields" do
          @wt.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
          @wt.field_contains("First name", "Ken").should be_true
          @wt.field_contains("Last name", "Brazier").should be_true
          @wt.field_contains("Life story", "story: I get testy").should be_true
        end

        it "clears a field" do
          @wt.set_fields("message" => "").should be_true
          @wt.field_contains("message", "").should be_true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          @wt.set_fields("Faust name" => "Ken", "Last name" => "Brazier").should be_false
        end

        it "cant find the last field" do
          @wt.set_fields("First name" => "Ken", "Lost name" => "Brazier").should be_false
        end
      end
    end
  end # set_fields


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
          @wt.field_contains("First name", "Marcus").should be_true
        end

        it "sets zero fields" do
          @wt.set_fields("").should be_true
        end

        it "sets several fields" do
          @wt.set_fields("First name" => "Ken", "Last name" => "Brazier", "Life story" => "My story\\; I get testy a lot.").should be_true
          @wt.field_contains("First name", "Ken").should be_true
          @wt.field_contains("Last name", "Brazier").should be_true
          @wt.field_contains("Life story", "story: I get testy").should be_true
        end

        it "clears a field" do
          @wt.set_fields("message" => "").should be_true
          @wt.field_contains("message", "").should be_true
        end
      end
    end

    context "fails when" do
      context "text fields with labels" do
        it "cant find the first field" do
          @wt.set_fields("Faust name" => "Ken", "Last name" => "Brazier").should be_false
        end

        it "cant find the last field" do
          @wt.set_fields("First name" => "Ken", "Lost name" => "Brazier").should be_false
        end
      end
    end
    after(:all) do
      @wt.set_fields_study_min('default')
    end
  end
end # set_fields

