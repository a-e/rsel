require 'spec/wt_spec_helper'

describe 'waiting' do
  before(:each) do
    @wt.visit("/").should be_true
  end

  describe "#page_loads_in_seconds_or_less" do
    context "passes when" do
      it "page is already loaded" do
        @wt.click_link("About this site").should be_true
        sleep 1
        @wt.page_loads_in_seconds_or_less(10).should be_true
      end
      it "page loads before the timeout" do
        @wt.click_link("Slow page").should be_true
        @wt.page_loads_in_seconds_or_less(10).should be_true
        @wt.see("This page takes a few seconds to load").should be_true
      end
    end

    context "fails when" do
      it "slow page does not load before the timeout" do
        @wt.click_link("Slow page").should be_true
        @wt.page_loads_in_seconds_or_less(1).should be_false
      end
    end
  end

  describe "#pause_seconds" do
    it "returns true" do
      @wt.pause_seconds(0).should == true
      @wt.pause_seconds(1).should == true
    end
  end
end

