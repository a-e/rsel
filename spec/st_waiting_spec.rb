require_relative 'st_spec_helper'

describe 'waiting' do
  before(:each) do
    expect(@st.visit("/")).to be true
  end

  describe "#page_loads_in_seconds_or_less" do
    context "passes when" do
      it "page is already loaded" do
        expect(@st.click_link("About this site")).to be true
        sleep 1
        expect(@st.page_loads_in_seconds_or_less(10)).to be true
      end
      it "page loads before the timeout" do
        expect(@st.click_link("Slow page")).to be true
        expect(@st.page_loads_in_seconds_or_less(10)).to be true
        expect(@st.see("This page takes a few seconds to load")).to be true
      end
    end

    context "fails when" do
      it "slow page does not load before the timeout" do
        expect(@st.click_link("Slow page")).to be true
        expect(@st.page_loads_in_seconds_or_less(1)).to be false
      end
    end
  end

  describe "#pause_seconds" do
    it "returns true" do
      expect(@st.pause_seconds(0)).to == true
      expect(@st.pause_seconds(1)).to == true
    end
  end
end

