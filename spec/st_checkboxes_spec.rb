require_relative 'st_spec_helper'

describe 'checkboxes' do
  before(:each) do
    expect(@st.visit("/form")).to be true
  end

  describe "#enable_checkbox" do
    context "passes when" do
      context "checkbox with label" do
        it "exists" do
          expect(@st.enable_checkbox("I like cheese")).to be true
          expect(@st.enable_checkbox("I like salami")).to be true
        end

        it "exists and is already checked" do
          @st.enable_checkbox("I like cheese")
          expect(@st.enable_checkbox("I like cheese")).to be true
        end

        it "exists within scope" do
          expect(@st.enable_checkbox("I like cheese", :within => "cheese_checkbox")).to be true
          expect(@st.enable_checkbox("I like salami", :within => "salami_checkbox")).to be true
        end

        it "exists in table row" do
          @st.visit("/table")
          expect(@st.enable_checkbox("Like", :in_row => "Marcus")).to be true
        end
      end

      context "checkbox with id=" do
        it "exists" do
          expect(@st.enable_checkbox("id=like_cheese")).to be true
        end
      end

      context "checkbox with xpath=" do
        it "exists" do
          expect(@st.enable_checkbox("xpath=//input[@id='like_cheese']")).to be true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          expect(@st.enable_checkbox("I dislike bacon")).to be false
          expect(@st.enable_checkbox("I like broccoli")).to be false
        end

        it "exists, but not within scope" do
          expect(@st.enable_checkbox("I like cheese", :within => "salami_checkbox")).to be false
          expect(@st.enable_checkbox("I like salami", :within => "cheese_checkbox")).to be false
        end

        it "exists, but not in table row" do
          @st.visit("/table")
          expect(@st.enable_checkbox("Like", :in_row => "Eric")).to be false
        end

        it "exists, but is read-only" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.enable_checkbox("I like salami")).to be false
        end
      end
    end
  end

  describe "#disable_checkbox" do
    context "passes when" do
      context "checkbox with label" do
        it "exists" do
          expect(@st.disable_checkbox("I like cheese")).to be true
          expect(@st.disable_checkbox("I like salami")).to be true
        end

        it "exists and is already unchecked" do
          @st.disable_checkbox("I like cheese")
          expect(@st.disable_checkbox("I like cheese")).to be true
        end

        it "exists within scope" do
          expect(@st.disable_checkbox("I like cheese", :within => "cheese_checkbox")).to be true
          expect(@st.disable_checkbox("I like salami", :within => "preferences_form")).to be true
        end

        it "exists in table row" do
          @st.visit("/table")
          expect(@st.disable_checkbox("Like", :in_row => "Marcus")).to be true
        end
      end

      context "checkbox with id=" do
        it "exists" do
          expect(@st.disable_checkbox("id=like_cheese")).to be true
        end
      end

      context "checkbox with xpath=" do
        it "exists" do
          expect(@st.disable_checkbox("xpath=//input[@id='like_cheese']")).to be true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          expect(@st.disable_checkbox("I dislike bacon")).to be false
          expect(@st.disable_checkbox("I like broccoli")).to be false
        end

        it "exists, but not within scope" do
          expect(@st.disable_checkbox("I like cheese", :within => "salami_checkbox")).to be false
          expect(@st.disable_checkbox("I like salami", :within => "cheese_checkbox")).to be false
        end

        it "exists, but not in table row" do
          @st.visit("/table")
          expect(@st.disable_checkbox("Like", :in_row => "Eric")).to be false
        end

        it "exists, but is read-only" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.disable_checkbox("I like cheese")).to be false
        end
      end
    end
  end

  describe "#checkbox_is_enabled" do
    context "passes when" do
      context "checkbox with label" do
        it "exists and is checked" do
          expect(@st.enable_checkbox("I like cheese")).to be true
          expect(@st.checkbox_is_enabled("I like cheese")).to be true
        end

        it "exists within scope and is checked" do
          expect(@st.enable_checkbox("I like cheese", :within => "cheese_checkbox")).to be true
          expect(@st.checkbox_is_enabled("I like cheese", :within => "cheese_checkbox")).to be true
        end

        it "exists in table row and is checked" do
          @st.visit("/table")
          expect(@st.enable_checkbox("Like", :in_row => "Ken")).to be true
          expect(@st.checkbox_is_enabled("Like", :in_row => "Ken")).to be true
        end

        it "exists and is checked, but read-only" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.checkbox_is_enabled("I like cheese")).to be true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          expect(@st.checkbox_is_enabled("I dislike bacon")).to be false
        end

        it "exists but is unchecked" do
          expect(@st.disable_checkbox("I like cheese")).to be true
          expect(@st.checkbox_is_enabled("I like cheese")).to be false
        end

        it "exists and is checked, but not within scope" do
          expect(@st.enable_checkbox("I like cheese", :within => "cheese_checkbox")).to be true
          expect(@st.checkbox_is_enabled("I like cheese", :within => "salami_checkbox")).to be false
        end

        it "exists and is checked, but not in table row" do
          @st.visit("/table")
          expect(@st.enable_checkbox("Like", :in_row => "Marcus")).to be true
          expect(@st.checkbox_is_enabled("Like", :in_row => "Eric")).to be false
        end
      end
    end
  end

  describe "#checkbox_is_disabled" do
    context "passes when" do
      context "checkbox with label" do
        it "exists and is unchecked" do
          expect(@st.disable_checkbox("I like cheese")).to be true
          expect(@st.checkbox_is_disabled("I like cheese")).to be true
        end

        it "exists within scope and is unchecked" do
          expect(@st.disable_checkbox("I like cheese", :within => "cheese_checkbox")).to be true
          expect(@st.checkbox_is_disabled("I like cheese", :within => "cheese_checkbox")).to be true
        end

        it "exists in table row and is unchecked" do
          @st.visit("/table")
          expect(@st.disable_checkbox("Like", :in_row => "Ken")).to be true
          expect(@st.checkbox_is_disabled("Like", :in_row => "Ken")).to be true
        end

        it "exists and is unchecked, but read-only" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.checkbox_is_disabled("I like salami")).to be true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          expect(@st.checkbox_is_disabled("I dislike bacon")).to be false
        end

        it "exists but is checked" do
          expect(@st.enable_checkbox("I like cheese")).to be true
          expect(@st.checkbox_is_disabled("I like cheese")).to be false
        end

        it "exists and is unchecked, but not within scope" do
          expect(@st.disable_checkbox("I like cheese", :within => "cheese_checkbox")).to be true
          expect(@st.checkbox_is_disabled("I like cheese", :within => "salami_checkbox")).to be false
        end

        it "exists and is unchecked, but not in table row" do
          @st.visit("/table")
          expect(@st.disable_checkbox("Like", :in_row => "Marcus")).to be true
          expect(@st.checkbox_is_disabled("Like", :in_row => "Eric")).to be false
        end
      end
    end
  end
end


