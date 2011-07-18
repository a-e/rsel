require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest do
  before(:all) do
    @st = Rsel::SeleniumTest.new('http://localhost:8070/')
    @st.open_browser
  end

  after(:all) do
    @st.close_browser
  end


  context "initialization" do
    it "sets correct default configuration" do
      @st.url.should == 'http://localhost:8070/'
      @st.browser.host.should == 'localhost'
      @st.browser.port.should == 4444
    end
  end


  context "visibility" do
    context "should see" do
      it "passes when text is present" do
        @st.should_see('Welcome').should == true
        @st.should_see('This is a Sinatra webapp').should == true
      end

      it "fails when text is absent" do
        @st.should_see('Nonexistent').should == false
        @st.should_see('Some bogus text').should == false
      end

      it "is case-sensitive" do
        @st.should_see('Sinatra webapp').should == true
        @st.should_see('sinatra Webapp').should == false
      end
    end

    context "should not see" do
      it "passes when text is absent" do
        @st.should_not_see('Nonexistent').should == true
        @st.should_not_see('Some bogus text').should == true
      end

      it "fails when test is present" do
        @st.should_not_see('Welcome').should == false
        @st.should_not_see('This is a Sinatra webapp').should == false
      end

      it "is case-sensitive" do
        @st.should_not_see('Sinatra webapp').should == false
        @st.should_not_see('sinatra Webapp').should == true
      end
    end
  end
end

