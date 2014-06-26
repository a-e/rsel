require_relative 'st_spec_helper'

describe 'dropdowns' do
  before(:each) do
    expect(@st.visit("/form")).to be true
  end

  context "#select_from_dropdown" do
    context "passes when" do
      it "option exists in the dropdown" do
        expect(@st.select_from_dropdown("Tall", "Height")).to be true
        expect(@st.select_from_dropdown("Medium", "Weight")).to be true
      end

      it "option exists in the dropdown within scope" do
        expect(@st.select_from_dropdown("Tall", "Height", :within => "spouse_form")).to be true
      end

      it "option exists in the dropdown in table row" do
        @st.visit("/table")
        expect(@st.select_from_dropdown("Male", "Gender", :in_row => "Eric")).to be true
      end
    end

    context "fails when" do
      it "no such dropdown exists" do
        expect(@st.select_from_dropdown("Over easy", "Eggs")).to be false
      end

      it "dropdown exists, but the option doesn't" do
        expect(@st.select_from_dropdown("Giant", "Height")).to be false
        expect(@st.select_from_dropdown("Obese", "Weight")).to be false
      end

      it "dropdown exists, but is read-only" do
        expect(@st.visit("/readonly_form")).to be true
        expect(@st.select_from_dropdown("Tall", "Height")).to be false
      end

      it "dropdown exists, but not within scope" do
        expect(@st.select_from_dropdown("Medium", "Weight", :within => "spouse_form")).to be false
      end

      it "dropdown exists, but not in table row" do
        @st.visit("/table")
        expect(@st.select_from_dropdown("Female", "Gender", :in_row => "First name")).to be false
      end
    end
  end

  context "#dropdown_includes" do
    context "passes when" do
      it "option exists in the dropdown" do
        expect(@st.dropdown_includes("Height", "Tall")).to be true
        expect(@st.dropdown_includes("Weight", "Medium")).to be true
      end

      it "option exists in a read-only dropdown" do
        expect(@st.visit("/readonly_form")).to be true
        expect(@st.dropdown_includes("Height", "Tall")).to be true
      end
    end

    context "fails when" do
      it "dropdown exists, but the option doesn't" do
        expect(@st.dropdown_includes("Height", "Giant")).to be false
        expect(@st.dropdown_includes("Weight", "Obese")).to be false
      end

      it "no such dropdown exists" do
        expect(@st.dropdown_includes("Eggs", "Over easy")).to be false
      end
    end
  end

  context "#dropdown_equals" do
    context "passes when" do
      it "option is selected in the dropdown" do
        ["Short", "Average", "Tall"].each do |height|
          @st.select_from_dropdown(height, "Height")
          expect(@st.dropdown_equals("Height", height)).to be true
        end
      end

      it "option is selected in a read-only dropdown" do
        expect(@st.visit("/readonly_form")).to be true
        expect(@st.dropdown_equals("Height", "Average")).to be true
      end

      it "option is selected in the dropdown, within scope" do
        ["Short", "Average", "Tall"].each do |height|
          @st.select_from_dropdown(height, "Height", :within => "spouse_form")
          expect(@st.dropdown_equals("Height", height, :within => "spouse_form")).to be true
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
        expect(@st.dropdown_equals("Eggs", "Over easy")).to be false
      end

      it "dropdown exists, but the option is not selected" do
        @st.select_from_dropdown("Short", "Height")
        expect(@st.dropdown_equals("Height", "Average")).to be false
        expect(@st.dropdown_equals("Height", "Tall")).to be false

        @st.select_from_dropdown("Average", "Height")
        expect(@st.dropdown_equals("Height", "Short")).to be false
        expect(@st.dropdown_equals("Height", "Tall")).to be false

        @st.select_from_dropdown("Tall", "Height")
        expect(@st.dropdown_equals("Height", "Short")).to be false
        expect(@st.dropdown_equals("Height", "Average")).to be false
      end

      it "dropdown exists, and option is selected, but not within scope" do
        @st.select_from_dropdown("Tall", "Height", :within => "person_form")
        @st.select_from_dropdown("Short", "Height", :within => "spouse_form")
        expect(@st.dropdown_equals("Height", "Tall", :within => "spouse_form")).to be false
      end

      it "dropdown exists, and option is selected, but not in table row" do
        @st.visit("/table")
        @st.select_from_dropdown("Female", "Gender", :in_row => "Eric")
        @st.select_from_dropdown("Male", "Gender", :in_row => "Marcus")
        expect(@st.dropdown_equals("Gender", "Female", :in_row => "Marcus")).to be false
      end
    end
  end
end

