require_relative 'st_spec_helper'

describe 'alerts' do
  describe "#see_alert_within_seconds" do
    before(:each) do
      expect(@st.visit("/alert")).to be true
    end

    context "passes when" do
      it "sees a generic alert" do
        @st.click("Alert me now")
        expect(@st.see_alert_within_seconds).to be true
      end
      it "sees a generic alert in time" do
        @st.click("Alert me now")
        expect(@st.see_alert_within_seconds(10)).to be true
      end
      it "sees the specific alert" do
        @st.click("Alert me now")
        expect(@st.see_alert_within_seconds("Ruby alert! Automate your workstations!")).to be true
      end
      it "sees the specific alert in time" do
        @st.click("Alert me soon")
        expect(@st.see_alert_within_seconds("Ruby alert! Automate your workstations!", 10)).to be true
      end
    end

    context "fails when" do
      it "does not see a generic alert in time" do
        @st.click("Alert me soon")
        expect(@st.see_alert_within_seconds(1)).to be false
        # Clean up the alert, to avoid random errors later.
        #expect(@st.see_alert_within_seconds("Ruby alert! Automate your workstations!", 10)).to be true
      end
      it "does not see the specific alert in time" do
        @st.click("Alert me soon")
        expect(@st.see_alert_within_seconds("Ruby alert! Automate your workstations!", 1)).to be false
        # Clean up the alert, to avoid random errors later.
        #expect(@st.see_alert_within_seconds("Ruby alert! Automate your workstations!", 10)).to be true
      end
      it "sees a different alert message" do
        @st.click("Alert me now")
        expect(@st.see_alert_within_seconds("Ruby alert! Man your workstations!", 10)).to be false
      end
    end

  end
end
