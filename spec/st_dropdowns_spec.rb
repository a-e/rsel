require_relative 'st_spec_helper'

describe 'dropdowns' do
  before(:each) do
    @st.visit("/form").should be_true
  end

  context "#select_from_dropdown" do
    context "passes when" do
      it "option exists in the dropdown" do
        @st.select_from_dropdown("Tall", "Height").should be_true
        @st.select_from_dropdown("Medium", "Weight").should be_true
      end

      it "option exists in the dropdown within scope" do
        @st.select_from_dropdown("Tall", "Height", :within => "spouse_form").should be_true
      end

      it "option exists in the dropdown in table row" do
        @st.visit("/table")
        @st.select_from_dropdown("Male", "Gender", :in_row => "Eric").should be_true
      end
    end

    context "fails when" do
      it "no such dropdown exists" do
        @st.select_from_dropdown("Over easy", "Eggs").should be_false
      end

      it "dropdown exists, but the option doesn't" do
        @st.select_from_dropdown("Giant", "Height").should be_false
        @st.select_from_dropdown("Obese", "Weight").should be_false
      end

      it "dropdown exists, but is read-only" do
        @st.visit("/readonly_form").should be_true
        @st.select_from_dropdown("Tall", "Height").should be_false
      end

      it "dropdown exists, but not within scope" do
        @st.select_from_dropdown("Medium", "Weight", :within => "spouse_form").should be_false
      end

      it "dropdown exists, but not in table row" do
        @st.visit("/table")
        @st.select_from_dropdown("Female", "Gender", :in_row => "First name").should be_false
      end
    end
  end

  context "#dropdown_includes" do
    context "passes when" do
      it "option exists in the dropdown" do
        @st.dropdown_includes("Height", "Tall").should be_true
        @st.dropdown_includes("Weight", "Medium").should be_true
      end

      it "option exists in a read-only dropdown" do
        @st.visit("/readonly_form").should be_true
        @st.dropdown_includes("Height", "Tall").should be_true
      end
    end

    context "fails when" do
      it "dropdown exists, but the option doesn't" do
        @st.dropdown_includes("Height", "Giant").should be_false
        @st.dropdown_includes("Weight", "Obese").should be_false
      end

      it "no such dropdown exists" do
        @st.dropdown_includes("Eggs", "Over easy").should be_false
      end
    end
  end

  context "#dropdown_equals" do
    context "passes when" do
      it "option is selected in the dropdown" do
        ["Short", "Average", "Tall"].each do |height|
          @st.select_from_dropdown(height, "Height")
          @st.dropdown_equals("Height", height).should be_true
        end
      end

      it "option is selected in a read-only dropdown" do
        @st.visit("/readonly_form").should be_true
        @st.dropdown_equals("Height", "Average").should be_true
      end

      it "option is selected in the dropdown, within scope" do
        ["Short", "Average", "Tall"].each do |height|
          @st.select_from_dropdown(height, "Height", :within => "spouse_form")
          @st.dropdown_equals("Height", height, :within => "spouse_form").should be_true
        end
      end

      it "option is selected in the dropdown, in table row" do
        @st.visit("/table")
        ["Male", "Female"].each do |gender|
          @st.select_from_dropdown(gender, "Gender", :in_row => "Eric")
          @st.dropdown_equals("Gender", gender, :in_row => "Eric")
        end
      end
    end

    context "fails when" do
      it "no such dropdown exists" do
        @st.dropdown_equals("Eggs", "Over easy").should be_false
      end

      it "dropdown exists, but the option is not selected" do
        @st.select_from_dropdown("Short", "Height")
        @st.dropdown_equals("Height", "Average").should be_false
        @st.dropdown_equals("Height", "Tall").should be_false

        @st.select_from_dropdown("Average", "Height")
        @st.dropdown_equals("Height", "Short").should be_false
        @st.dropdown_equals("Height", "Tall").should be_false

        @st.select_from_dropdown("Tall", "Height")
        @st.dropdown_equals("Height", "Short").should be_false
        @st.dropdown_equals("Height", "Average").should be_false
      end

      it "dropdown exists, and option is selected, but not within scope" do
        @st.select_from_dropdown("Tall", "Height", :within => "person_form")
        @st.select_from_dropdown("Short", "Height", :within => "spouse_form")
        @st.dropdown_equals("Height", "Tall", :within => "spouse_form").should be_false
      end

      it "dropdown exists, and option is selected, but not in table row" do
        @st.visit("/table")
        @st.select_from_dropdown("Female", "Gender", :in_row => "Eric")
        @st.select_from_dropdown("Male", "Gender", :in_row => "Marcus")
        @st.dropdown_equals("Gender", "Female", :in_row => "Marcus").should be_false
      end
    end
  end
end

