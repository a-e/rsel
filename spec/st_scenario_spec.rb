require_relative 'st_spec_helper'

describe 'scenarios' do
  before(:each) do
    expect(@st.visit('/')).to be true
  end

  describe "#begin_scenario" do
    it "returns true" do
      expect(@st.begin_scenario).to be true
    end

    it "sets found_failure to false" do
      @st.found_failure = true
      @st.begin_scenario
      expect(@st.found_failure).to be false
    end
  end

  describe "#end_scenario" do
    it "returns true" do
      expect(@st.end_scenario).to be true
    end
  end
end

