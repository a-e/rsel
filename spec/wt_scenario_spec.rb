require 'spec/wt_spec_helper'

describe 'scenarios' do
  before(:each) do
    @wt.visit('/').should be_true
  end

  describe "#begin_scenario" do
    it "returns true" do
      @wt.begin_scenario.should be_true
    end

    it "sets found_failure to false" do
      @wt.found_failure = true
      @wt.begin_scenario
      @wt.found_failure.should be_false
    end
  end

  describe "#end_scenario" do
    it "returns true" do
      @wt.end_scenario.should be_true
    end
  end
end

