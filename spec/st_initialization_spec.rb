require 'spec/st_spec_helper'

describe 'initialization' do
  it "sets correct default configuration" do
    st = Rsel::SeleniumTest.new('http://some.host.org:8070/')
    st.url.should == "http://some.host.org:8070/"
    # Defaults
    st.browser.host.should == "localhost"
    st.browser.port.should == 4444
    st.browser.browser_string.should == "*firefox"
    st.browser.default_timeout_in_seconds.should == 300
    st.stop_on_failure.should == false
    st.found_failure.should == false
  end

  context "stop_on_failure option" do
    it "can be initialized with a string" do
      st = Rsel::SeleniumTest.new('localhost', :stop_on_failure => 'true')
      st.stop_on_failure.should be_true
      st = Rsel::SeleniumTest.new('localhost', :stop_on_failure => 'FALSE')
      st.stop_on_failure.should be_false
    end

    it "can be initialized with a boolean" do
      st = Rsel::SeleniumTest.new('localhost', :stop_on_failure => true)
      st.stop_on_failure.should be_true
      st = Rsel::SeleniumTest.new('localhost', :stop_on_failure => false)
      st.stop_on_failure.should be_false
    end
  end

end

