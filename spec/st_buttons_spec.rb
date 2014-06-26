require_relative 'st_spec_helper'

describe 'buttons' do
  before(:each) do
    @st.visit("/form").should be true
  end

  describe "#click_button" do
    context "passes when" do
      context "studying and " do
        it "button exists and is enabled" do
          @st.begin_study
          @st.click_button("Submit person form").should be true
          @st.end_study
        end

        it "button exists within scope" do
          @st.begin_study
          @st.click_button("Submit person form", :within => "person_form").should be true
          @st.end_study
        end
      end

      it "button exists and is enabled" do
        @st.click_button("Submit person form").should be true
      end

      it "button exists within scope" do
        @st.click_button("Submit person form", :within => "person_form").should be true
      end

      it "button exists in table row" do
        # TODO
      end
    end

    context "fails when" do
      it "button does not exist" do
        @st.click_button("No such button").should be false
      end

      it "button exists, but not within scope" do
        @st.click_button("Submit person form", :within => "spouse_form").should be false
      end

      it "button exists, but not in table row" do
        # TODO
      end

      it "button exists, but is read-only" do
        @st.visit("/readonly_form").should be true
        @st.click_button("Submit person form").should be false
      end
    end
  end


  describe "#button_exists" do
    context "passes when" do
      context "button with text" do
        it "exists" do
          @st.button_exists("Submit person form").should be true
          @st.button_exists("Save preferences").should be true
        end

        it "exists within scope" do
          @st.button_exists("Submit person form", :within => "person_form").should be true
          @st.button_exists("Submit spouse form", :within => "spouse_form").should be true
        end

        it "exists in table row" do
          # TODO
        end
      end
    end

    context "fails when" do
      it "no such button exists" do
        @st.button_exists("Apple").should be false
        @st.button_exists("Big Red").should be false
      end

      it "button exists, but not within scope" do
        @st.button_exists("Submit spouse form", :within => "person_form").should be false
        @st.button_exists("Submit person form", :within => "spouse_form").should be false
      end

      it "button exists, but not in table row" do
        # TODO
      end
    end
  end

end

