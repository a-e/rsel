require_relative 'st_spec_helper'

describe 'buttons' do
  before(:each) do
    expect(@st.visit("/form")).to be true
  end

  describe "#click_button" do
    context "passes when" do
      context "studying and " do
        it "button exists and is enabled" do
          @st.begin_study
          expect(@st.click_button("Submit person form")).to be true
          @st.end_study
        end

        it "button exists within scope" do
          @st.begin_study
          expect(@st.click_button("Submit person form", :within => "person_form")).to be true
          @st.end_study
        end
      end

      it "button exists and is enabled" do
        expect(@st.click_button("Submit person form")).to be true
      end

      it "button exists within scope" do
        expect(@st.click_button("Submit person form", :within => "person_form")).to be true
      end

      it "button exists in table row" do
        # TODO
      end
    end

    context "fails when" do
      it "button does not exist" do
        expect(@st.click_button("No such button")).to be false
      end

      it "button exists, but not within scope" do
        expect(@st.click_button("Submit person form", :within => "spouse_form")).to be false
      end

      it "button exists, but not in table row" do
        # TODO
      end

      it "button exists, but is read-only" do
        expect(@st.visit("/readonly_form")).to be true
        expect(@st.click_button("Submit person form")).to be false
      end
    end
  end


  describe "#button_exists" do
    context "passes when" do
      context "button with text" do
        it "exists" do
          expect(@st.button_exists("Submit person form")).to be true
          expect(@st.button_exists("Save preferences")).to be true
        end

        it "exists within scope" do
          expect(@st.button_exists("Submit person form", :within => "person_form")).to be true
          expect(@st.button_exists("Submit spouse form", :within => "spouse_form")).to be true
        end

        it "exists in table row" do
          # TODO
        end
      end
    end

    context "fails when" do
      it "no such button exists" do
        expect(@st.button_exists("Apple")).to be false
        expect(@st.button_exists("Big Red")).to be false
      end

      it "button exists, but not within scope" do
        expect(@st.button_exists("Submit spouse form", :within => "person_form")).to be false
        expect(@st.button_exists("Submit person form", :within => "spouse_form")).to be false
      end

      it "button exists, but not in table row" do
        # TODO
      end
    end
  end

end

