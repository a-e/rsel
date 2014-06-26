require_relative 'st_spec_helper'

describe 'waiting' do
  before(:each) do
    @st.visit("/").should be true
  end

  describe "#page_loads_in_seconds_or_less" do
    context "passes when" do
      it "page is already loaded" do
        @st.click_link("About this site").should be true
        sleep 1
        @st.page_loads_in_seconds_or_less(10).should be true
      end
      it "page loads before the timeout" do
        @st.click_link("Slow page").should be true
        @st.page_loads_in_seconds_or_less(10).should be true
        @st.see("This page takes a few seconds to load").should be true
      end
    end

    context "fails when" do
      it "slow page does not load before the timeout" do
        @st.click_link("Slow page").should be true
        @st.page_loads_in_seconds_or_less(1).should be false
      end
    end
  end

  describe "#pause_seconds" do
    it "returns true" do
      @st.pause_seconds(0).should == true
      @st.pause_seconds(1).should == true
    end
  end
end

