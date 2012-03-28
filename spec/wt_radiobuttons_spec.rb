require 'spec/wt_spec_helper'

describe 'radiobuttons' do
  before(:each) do
    @wt.visit("/form").should be_true
  end

  context "#select_radio" do
    context "passes when" do
      context "radiobutton with label" do
        it "exists" do
          @wt.select_radio("Briefs").should be_true
        end

        it "exists within scope" do
          @wt.select_radio("Briefs", :within => "clothing").should be_true
        end

        it "exists in table row" do
          # TODO
        end
      end
    end

    context "fails when" do
      context "radiobutton with label" do
        it "does not exist" do
          @wt.select_radio("Naked").should be_false
        end

        it "exists, but not within scope" do
          @wt.select_radio("Briefs", :within => "food").should be_false
        end

        it "exists, but is read-only" do
          @wt.visit("/readonly_form").should be_true
          @wt.select_radio("Boxers").should be_false
        end

        it "exists, but not in table row" do
          # TODO
        end
      end
    end
  end

  describe "#radio_is_enabled" do
    context "passes when" do
      context "radiobutton with label" do
        it "exists, and is enabled" do
          @wt.select_radio("Briefs")
          @wt.radio_is_enabled("Briefs").should be_true
        end

        it "exists within scope, and is enabled" do
          @wt.select_radio("Briefs", :within => "clothing")
          @wt.radio_is_enabled("Briefs", :within => "clothing").should be_true
        end

        it "exists in table row, and is enabled" do
          # TODO
        end
      end
    end

    context "fails when" do
      context "radiobutton with label" do
        it "does not exist" do
          @wt.radio_is_enabled("Naked").should be_false
        end

        it "exists, but is not enabled" do
          @wt.select_radio("Briefs")
          @wt.radio_is_enabled("Boxers").should be_false
        end

        it "exists and is enabled, but not within scope" do
          @wt.select_radio("Briefs", :within => "clothing")
          @wt.radio_is_enabled("Briefs", :within => "food").should be_false
        end
      end
    end
  end

  describe "#radio_is_disabled" do
    context "passes when" do
      context "radiobutton with label" do
        it "exists, and is disabled" do
          @wt.select_radio("Briefs")
          @wt.radio_is_disabled("Boxers").should be_true
        end

        it "exists within scope, and is disabled" do
          @wt.select_radio("Briefs", :within => "clothing")
          @wt.radio_is_disabled("Boxers", :within => "clothing").should be_true
        end

        it "exists in table row, and is disabled" do
          # TODO
        end
      end
    end

    context "fails when" do
      context "radiobutton with label" do
        it "does not exist" do
          @wt.radio_is_disabled("Naked").should be_false
        end

        it "exists, but is enabled" do
          @wt.select_radio("Briefs")
          @wt.radio_is_disabled("Briefs").should be_false
        end

        it "exists and is disabled, but not within scope" do
          @wt.select_radio("Briefs", :within => "clothing")
          @wt.radio_is_disabled("Briefs", :within => "food").should be_false
        end
      end
    end
  end
end

