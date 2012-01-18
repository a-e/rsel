require 'spec/spec_helper'

describe 'scenarios' do
  before(:each) do
    @st.visit('/').should be_true
  end

  describe "#begin_scenario" do
    it "returns true" do
      @st.begin_scenario.should be_true
    end

    it "sets found_failure to false" do
      @st.found_failure = true
      @st.begin_scenario
      @st.found_failure.should be_false
    end
  end

  describe "#end_scenario" do
    it "returns true" do
      @st.end_scenario.should be_true
    end
  end
end

