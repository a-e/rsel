require_relative 'st_spec_helper'

describe 'alerts' do
  describe "#see_alert_within_seconds" do
    before(:each) do
      @st.visit("/alert").should be true
    end

    context "passes when" do
      it "sees a generic alert" do
        @st.click("Alert me now")
        @st.see_alert_within_seconds.should be true
      end
      it "sees a generic alert in time" do
        @st.click("Alert me now")
        @st.see_alert_within_seconds(10).should be true
      end
      it "sees the specific alert" do
        @st.click("Alert me now")
        @st.see_alert_within_seconds("Ruby alert! Automate your workstations!").should be true
      end
      it "sees the specific alert in time" do
        @st.click("Alert me soon")
        @st.see_alert_within_seconds("Ruby alert! Automate your workstations!", 10).should be true
      end
    end

    context "fails when" do
      it "does not see a generic alert in time" do
        @st.click("Alert me soon")
        @st.see_alert_within_seconds(1).should be false
        # Clean up the alert, to avoid random errors later.
        #@st.see_alert_within_seconds("Ruby alert! Automate your workstations!", 10).should be true
      end
      it "does not see the specific alert in time" do
        @st.click("Alert me soon")
        @st.see_alert_within_seconds("Ruby alert! Automate your workstations!", 1).should be false
        # Clean up the alert, to avoid random errors later.
        #@st.see_alert_within_seconds("Ruby alert! Automate your workstations!", 10).should be true
      end
      it "sees a different alert message" do
        @st.click("Alert me now")
        @st.see_alert_within_seconds("Ruby alert! Man your workstations!", 10).should be false
      end
    end

  end
end
