require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest do
  before(:all) do
    @st = Rsel::SeleniumTest.new('http://localhost:8070/')
    @st.open_browser
  end

  after(:all) do
    @st.close_browser
  end

  context "should see" do
    it "passes when text is present" do
      @st.should_see('Homepage').should == true
    end

    it "fails when test is not present" do
      @st.should_see('Nonexistent').should == false
    end
  end
end

