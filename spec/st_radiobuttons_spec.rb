require_relative 'st_spec_helper'

describe 'radiobuttons' do
  before(:each) do
    expect(@st.visit("/form")).to be true
  end

  context "#select_radio" do
    context "passes when" do
      context "radiobutton with label" do
        it "exists" do
          expect(@st.select_radio("Briefs")).to be true
        end

        it "exists within scope" do
          expect(@st.select_radio("Briefs", :within => "clothing")).to be true
        end

        it "exists in table row" do
          # TODO
        end
      end
    end

    context "fails when" do
      context "radiobutton with label" do
        it "does not exist" do
          expect(@st.select_radio("Naked")).to be false
        end

        it "exists, but not within scope" do
          expect(@st.select_radio("Briefs", :within => "food")).to be false
        end

        it "exists, but is read-only" do
          expect(@st.visit("/readonly_form")).to be true
          expect(@st.select_radio("Boxers")).to be false
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
          @st.select_radio("Briefs")
          expect(@st.radio_is_enabled("Briefs")).to be true
        end

        it "exists within scope, and is enabled" do
          @st.select_radio("Briefs", :within => "clothing")
          expect(@st.radio_is_enabled("Briefs", :within => "clothing")).to be true
        end

        it "exists in table row, and is enabled" do
          # TODO
        end
      end
    end

    context "fails when" do
      context "radiobutton with label" do
        it "does not exist" do
          expect(@st.radio_is_enabled("Naked")).to be false
        end

        it "exists, but is not enabled" do
          @st.select_radio("Briefs")
          expect(@st.radio_is_enabled("Boxers")).to be false
        end

        it "exists and is enabled, but not within scope" do
          @st.select_radio("Briefs", :within => "clothing")
          expect(@st.radio_is_enabled("Briefs", :within => "food")).to be false
        end
      end
    end
  end

  describe "#radio_is_disabled" do
    context "passes when" do
      context "radiobutton with label" do
        it "exists, and is disabled" do
          @st.select_radio("Briefs")
          expect(@st.radio_is_disabled("Boxers")).to be true
        end

        it "exists within scope, and is disabled" do
          @st.select_radio("Briefs", :within => "clothing")
          expect(@st.radio_is_disabled("Boxers", :within => "clothing")).to be true
        end

        it "exists in table row, and is disabled" do
          # TODO
        end
      end
    end

    context "fails when" do
      context "radiobutton with label" do
        it "does not exist" do
          expect(@st.radio_is_disabled("Naked")).to be false
        end

        it "exists, but is enabled" do
          @st.select_radio("Briefs")
          expect(@st.radio_is_disabled("Briefs")).to be false
        end

        it "exists and is disabled, but not within scope" do
          @st.select_radio("Briefs", :within => "clothing")
          expect(@st.radio_is_disabled("Briefs", :within => "food")).to be false
        end
      end
    end
  end
end

