require_relative 'st_spec_helper'

describe 'scenarios' do
  before(:each) do
    expect(@st.visit('/')).to be true
  end

  describe "#begin_scenario" do
    it "returns true" do
      @st.begin_scenario.should be true
    end

    it "sets found_failure to false" do
      @st.found_failure = true
      @st.begin_scenario
      @st.found_failure.should be false
    end
  end

  describe "#end_scenario" do
    it "returns true" do
      @st.end_scenario.should be true
    end
  end
end

