require 'spec/st_spec_helper'

describe 'checkboxes' do
  before(:each) do
    @st.visit("/form").should be_true
  end

  describe "#enable_checkbox" do
    context "passes when" do
      context "checkbox with label" do
        it "exists" do
          @st.enable_checkbox("I like cheese").should be_true
          @st.enable_checkbox("I like salami").should be_true
        end

        it "exists and is already checked" do
          @st.enable_checkbox("I like cheese")
          @st.enable_checkbox("I like cheese").should be_true
        end

        it "exists within scope" do
          @st.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @st.enable_checkbox("I like salami", :within => "salami_checkbox").should be_true
        end

        it "exists in table row" do
          @st.visit("/table")
          @st.enable_checkbox("Like", :in_row => "Marcus").should be_true
        end
      end

      context "checkbox with id=" do
        it "exists" do
          @st.enable_checkbox("id=like_cheese").should be_true
        end
      end

      context "checkbox with xpath=" do
        it "exists" do
          @st.enable_checkbox("xpath=//input[@id='like_cheese']").should be_true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          @st.enable_checkbox("I dislike bacon").should be_false
          @st.enable_checkbox("I like broccoli").should be_false
        end

        it "exists, but not within scope" do
          @st.enable_checkbox("I like cheese", :within => "salami_checkbox").should be_false
          @st.enable_checkbox("I like salami", :within => "cheese_checkbox").should be_false
        end

        it "exists, but not in table row" do
          @st.visit("/table")
          @st.enable_checkbox("Like", :in_row => "Eric").should be_false
        end

        it "exists, but is read-only" do
          @st.visit("/readonly_form").should be_true
          @st.enable_checkbox("I like salami").should be_false
        end
      end
    end
  end

  describe "#disable_checkbox" do
    context "passes when" do
      context "checkbox with label" do
        it "exists" do
          @st.disable_checkbox("I like cheese").should be_true
          @st.disable_checkbox("I like salami").should be_true
        end

        it "exists and is already unchecked" do
          @st.disable_checkbox("I like cheese")
          @st.disable_checkbox("I like cheese").should be_true
        end

        it "exists within scope" do
          @st.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @st.disable_checkbox("I like salami", :within => "preferences_form").should be_true
        end

        it "exists in table row" do
          @st.visit("/table")
          @st.disable_checkbox("Like", :in_row => "Marcus").should be_true
        end
      end

      context "checkbox with id=" do
        it "exists" do
          @st.disable_checkbox("id=like_cheese").should be_true
        end
      end

      context "checkbox with xpath=" do
        it "exists" do
          @st.disable_checkbox("xpath=//input[@id='like_cheese']").should be_true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          @st.disable_checkbox("I dislike bacon").should be_false
          @st.disable_checkbox("I like broccoli").should be_false
        end

        it "exists, but not within scope" do
          @st.disable_checkbox("I like cheese", :within => "salami_checkbox").should be_false
          @st.disable_checkbox("I like salami", :within => "cheese_checkbox").should be_false
        end

        it "exists, but not in table row" do
          @st.visit("/table")
          @st.disable_checkbox("Like", :in_row => "Eric").should be_false
        end

        it "exists, but is read-only" do
          @st.visit("/readonly_form").should be_true
          @st.disable_checkbox("I like cheese").should be_false
        end
      end
    end
  end

  describe "#checkbox_is_enabled" do
    context "passes when" do
      context "checkbox with label" do
        it "exists and is checked" do
          @st.enable_checkbox("I like cheese").should be_true
          @st.checkbox_is_enabled("I like cheese").should be_true
        end

        it "exists within scope and is checked" do
          @st.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @st.checkbox_is_enabled("I like cheese", :within => "cheese_checkbox").should be_true
        end

        it "exists in table row and is checked" do
          @st.visit("/table")
          @st.enable_checkbox("Like", :in_row => "Ken").should be_true
          @st.checkbox_is_enabled("Like", :in_row => "Ken").should be_true
        end

        it "exists and is checked, but read-only" do
          @st.visit("/readonly_form").should be_true
          @st.checkbox_is_enabled("I like cheese").should be_true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          @st.checkbox_is_enabled("I dislike bacon").should be_false
        end

        it "exists but is unchecked" do
          @st.disable_checkbox("I like cheese").should be_true
          @st.checkbox_is_enabled("I like cheese").should be_false
        end

        it "exists and is checked, but not within scope" do
          @st.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @st.checkbox_is_enabled("I like cheese", :within => "salami_checkbox").should be_false
        end

        it "exists and is checked, but not in table row" do
          @st.visit("/table")
          @st.enable_checkbox("Like", :in_row => "Marcus").should be_true
          @st.checkbox_is_enabled("Like", :in_row => "Eric").should be_false
        end
      end
    end
  end

  describe "#checkbox_is_disabled" do
    context "passes when" do
      context "checkbox with label" do
        it "exists and is unchecked" do
          @st.disable_checkbox("I like cheese").should be_true
          @st.checkbox_is_disabled("I like cheese").should be_true
        end

        it "exists within scope and is unchecked" do
          @st.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @st.checkbox_is_disabled("I like cheese", :within => "cheese_checkbox").should be_true
        end

        it "exists in table row and is unchecked" do
          @st.visit("/table")
          @st.disable_checkbox("Like", :in_row => "Ken").should be_true
          @st.checkbox_is_disabled("Like", :in_row => "Ken").should be_true
        end

        it "exists and is unchecked, but read-only" do
          @st.visit("/readonly_form").should be_true
          @st.checkbox_is_disabled("I like salami").should be_true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          @st.checkbox_is_disabled("I dislike bacon").should be_false
        end

        it "exists but is checked" do
          @st.enable_checkbox("I like cheese").should be_true
          @st.checkbox_is_disabled("I like cheese").should be_false
        end

        it "exists and is unchecked, but not within scope" do
          @st.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @st.checkbox_is_disabled("I like cheese", :within => "salami_checkbox").should be_false
        end

        it "exists and is unchecked, but not in table row" do
          @st.visit("/table")
          @st.disable_checkbox("Like", :in_row => "Marcus").should be_true
          @st.checkbox_is_disabled("Like", :in_row => "Eric").should be_false
        end
      end
    end
  end
end


