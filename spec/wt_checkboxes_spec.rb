require 'spec/wt_spec_helper'

describe 'checkboxes' do
  before(:each) do
    @wt.visit("/form").should be_true
  end

  describe "#enable_checkbox" do
    context "passes when" do
      context "checkbox with label" do
        it "exists" do
          @wt.enable_checkbox("I like cheese").should be_true
          @wt.enable_checkbox("I like salami").should be_true
        end

        it "exists and is already checked" do
          @wt.enable_checkbox("I like cheese")
          @wt.enable_checkbox("I like cheese").should be_true
        end

        it "exists within scope" do
          @wt.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @wt.enable_checkbox("I like salami", :within => "salami_checkbox").should be_true
        end

        it "exists in table row" do
          @wt.visit("/table")
          @wt.enable_checkbox("Like", :in_row => "Marcus").should be_true
        end
      end

      context "checkbox with id=" do
        it "exists" do
          @wt.enable_checkbox("id=like_cheese").should be_true
        end
      end

      context "checkbox with xpath=" do
        it "exists" do
          @wt.enable_checkbox("xpath=//input[@id='like_cheese']").should be_true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          @wt.enable_checkbox("I dislike bacon").should be_false
          @wt.enable_checkbox("I like broccoli").should be_false
        end

        it "exists, but not within scope" do
          @wt.enable_checkbox("I like cheese", :within => "salami_checkbox").should be_false
          @wt.enable_checkbox("I like salami", :within => "cheese_checkbox").should be_false
        end

        it "exists, but not in table row" do
          @wt.visit("/table")
          @wt.enable_checkbox("Like", :in_row => "Eric").should be_false
        end

        it "exists, but is read-only" do
          @wt.visit("/readonly_form").should be_true
          @wt.enable_checkbox("I like salami").should be_false
        end
      end
    end
  end

  describe "#disable_checkbox" do
    context "passes when" do
      context "checkbox with label" do
        it "exists" do
          @wt.disable_checkbox("I like cheese").should be_true
          @wt.disable_checkbox("I like salami").should be_true
        end

        it "exists and is already unchecked" do
          @wt.disable_checkbox("I like cheese")
          @wt.disable_checkbox("I like cheese").should be_true
        end

        it "exists within scope" do
          @wt.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @wt.disable_checkbox("I like salami", :within => "preferences_form").should be_true
        end

        it "exists in table row" do
          @wt.visit("/table")
          @wt.disable_checkbox("Like", :in_row => "Marcus").should be_true
        end
      end

      context "checkbox with id=" do
        it "exists" do
          @wt.disable_checkbox("id=like_cheese").should be_true
        end
      end

      context "checkbox with xpath=" do
        it "exists" do
          @wt.disable_checkbox("xpath=//input[@id='like_cheese']").should be_true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          @wt.disable_checkbox("I dislike bacon").should be_false
          @wt.disable_checkbox("I like broccoli").should be_false
        end

        it "exists, but not within scope" do
          @wt.disable_checkbox("I like cheese", :within => "salami_checkbox").should be_false
          @wt.disable_checkbox("I like salami", :within => "cheese_checkbox").should be_false
        end

        it "exists, but not in table row" do
          @wt.visit("/table")
          @wt.disable_checkbox("Like", :in_row => "Eric").should be_false
        end

        it "exists, but is read-only" do
          @wt.visit("/readonly_form").should be_true
          @wt.disable_checkbox("I like cheese").should be_false
        end
      end
    end
  end

  describe "#checkbox_is_enabled" do
    context "passes when" do
      context "checkbox with label" do
        it "exists and is checked" do
          @wt.enable_checkbox("I like cheese").should be_true
          @wt.checkbox_is_enabled("I like cheese").should be_true
        end

        it "exists within scope and is checked" do
          @wt.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @wt.checkbox_is_enabled("I like cheese", :within => "cheese_checkbox").should be_true
        end

        it "exists in table row and is checked" do
          @wt.visit("/table")
          @wt.enable_checkbox("Like", :in_row => "Ken").should be_true
          @wt.checkbox_is_enabled("Like", :in_row => "Ken").should be_true
        end

        it "exists and is checked, but read-only" do
          @wt.visit("/readonly_form").should be_true
          @wt.checkbox_is_enabled("I like cheese").should be_true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          @wt.checkbox_is_enabled("I dislike bacon").should be_false
        end

        it "exists but is unchecked" do
          @wt.disable_checkbox("I like cheese").should be_true
          @wt.checkbox_is_enabled("I like cheese").should be_false
        end

        it "exists and is checked, but not within scope" do
          @wt.enable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @wt.checkbox_is_enabled("I like cheese", :within => "salami_checkbox").should be_false
        end

        it "exists and is checked, but not in table row" do
          @wt.visit("/table")
          @wt.enable_checkbox("Like", :in_row => "Marcus").should be_true
          @wt.checkbox_is_enabled("Like", :in_row => "Eric").should be_false
        end
      end
    end
  end

  describe "#checkbox_is_disabled" do
    context "passes when" do
      context "checkbox with label" do
        it "exists and is unchecked" do
          @wt.disable_checkbox("I like cheese").should be_true
          @wt.checkbox_is_disabled("I like cheese").should be_true
        end

        it "exists within scope and is unchecked" do
          @wt.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @wt.checkbox_is_disabled("I like cheese", :within => "cheese_checkbox").should be_true
        end

        it "exists in table row and is unchecked" do
          @wt.visit("/table")
          @wt.disable_checkbox("Like", :in_row => "Ken").should be_true
          @wt.checkbox_is_disabled("Like", :in_row => "Ken").should be_true
        end

        it "exists and is unchecked, but read-only" do
          @wt.visit("/readonly_form").should be_true
          @wt.checkbox_is_disabled("I like salami").should be_true
        end
      end
    end

    context "fails when" do
      context "checkbox with label" do
        it "does not exist" do
          @wt.checkbox_is_disabled("I dislike bacon").should be_false
        end

        it "exists but is checked" do
          @wt.enable_checkbox("I like cheese").should be_true
          @wt.checkbox_is_disabled("I like cheese").should be_false
        end

        it "exists and is unchecked, but not within scope" do
          @wt.disable_checkbox("I like cheese", :within => "cheese_checkbox").should be_true
          @wt.checkbox_is_disabled("I like cheese", :within => "salami_checkbox").should be_false
        end

        it "exists and is unchecked, but not in table row" do
          @wt.visit("/table")
          @wt.disable_checkbox("Like", :in_row => "Marcus").should be_true
          @wt.checkbox_is_disabled("Like", :in_row => "Eric").should be_false
        end
      end
    end
  end
end


