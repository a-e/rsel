require_relative 'wt_spec_helper'

describe 'dropdowns' do
  before(:each) do
    @wt.visit("/form").should be_true
  end

  context "#select_from_dropdown" do
    context "passes when" do
      it "option exists in the dropdown" do
        @wt.select_from_dropdown("Tall", "Height").should be_true
        @wt.select_from_dropdown("Medium", "Weight").should be_true
      end

      it "option exists in the dropdown within scope" do
        @wt.select_from_dropdown("Tall", "Height", :within => "spouse_form").should be_true
      end

      it "option exists in the dropdown in table row" do
        @wt.visit("/table")
        @wt.select_from_dropdown("Male", "Gender", :in_row => "Eric").should be_true
      end
    end

    context "fails when" do
      it "no such dropdown exists" do
        @wt.select_from_dropdown("Over easy", "Eggs").should be_false
      end

      it "dropdown exists, but the option doesn't" do
        @wt.select_from_dropdown("Giant", "Height").should be_false
        @wt.select_from_dropdown("Obese", "Weight").should be_false
      end

      it "dropdown exists, but is read-only" do
        @wt.visit("/readonly_form").should be_true
        @wt.select_from_dropdown("Tall", "Height").should be_false
      end

      it "dropdown exists, but not within scope" do
        @wt.select_from_dropdown("Medium", "Weight", :within => "spouse_form").should be_false
      end

      it "dropdown exists, but not in table row" do
        @wt.visit("/table")
        @wt.select_from_dropdown("Female", "Gender", :in_row => "First name").should be_false
      end
    end
  end

  context "#dropdown_includes" do
    context "passes when" do
      it "option exists in the dropdown" do
        @wt.dropdown_includes("Height", "Tall").should be_true
        @wt.dropdown_includes("Weight", "Medium").should be_true
      end

      it "option exists in a read-only dropdown" do
        @wt.visit("/readonly_form").should be_true
        @wt.dropdown_includes("Height", "Tall").should be_true
      end
    end

    context "fails when" do
      it "dropdown exists, but the option doesn't" do
        @wt.dropdown_includes("Height", "Giant").should be_false
        @wt.dropdown_includes("Weight", "Obese").should be_false
      end

      it "no such dropdown exists" do
        @wt.dropdown_includes("Eggs", "Over easy").should be_false
      end
    end
  end

  context "#dropdown_equals" do
    context "passes when" do
      it "option is selected in the dropdown" do
        ["Short", "Average", "Tall"].each do |height|
          @wt.select_from_dropdown(height, "Height")
          @wt.dropdown_equals("Height", height).should be_true
        end
      end

      it "option is selected in a read-only dropdown" do
        @wt.visit("/readonly_form").should be_true
        @wt.dropdown_equals("Height", "Average").should be_true
      end

      it "option is selected in the dropdown, within scope" do
        ["Short", "Average", "Tall"].each do |height|
          @wt.select_from_dropdown(height, "Height", :within => "spouse_form")
          @wt.dropdown_equals("Height", height, :within => "spouse_form").should be_true
        end
      end

      it "option is selected in the dropdown, in table row" do
        @wt.visit("/table")
        ["Male", "Female"].each do |gender|
          @wt.select_from_dropdown(gender, "Gender", :in_row => "Eric")
          @wt.dropdown_equals("Gender", gender, :in_row => "Eric")
        end
      end
    end

    context "fails when" do
      it "no such dropdown exists" do
        @wt.dropdown_equals("Eggs", "Over easy").should be_false
      end

      it "dropdown exists, but the option is not selected" do
        @wt.select_from_dropdown("Short", "Height")
        @wt.dropdown_equals("Height", "Average").should be_false
        @wt.dropdown_equals("Height", "Tall").should be_false

        @wt.select_from_dropdown("Average", "Height")
        @wt.dropdown_equals("Height", "Short").should be_false
        @wt.dropdown_equals("Height", "Tall").should be_false

        @wt.select_from_dropdown("Tall", "Height")
        @wt.dropdown_equals("Height", "Short").should be_false
        @wt.dropdown_equals("Height", "Average").should be_false
      end

      it "dropdown exists, and option is selected, but not within scope" do
        @wt.select_from_dropdown("Tall", "Height", :within => "person_form")
        @wt.select_from_dropdown("Short", "Height", :within => "spouse_form")
        @wt.dropdown_equals("Height", "Tall", :within => "spouse_form").should be_false
      end

      it "dropdown exists, and option is selected, but not in table row" do
        @wt.visit("/table")
        @wt.select_from_dropdown("Female", "Gender", :in_row => "Eric")
        @wt.select_from_dropdown("Male", "Gender", :in_row => "Marcus")
        @wt.dropdown_equals("Gender", "Female", :in_row => "Marcus").should be_false
      end
    end
  end
end

