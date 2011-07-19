require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest, 'initialization' do
  before(:each) do
    @st.visit('/')
  end

  it "sets correct default configuration" do
    @st.url.should == 'http://localhost:8070/'
    @st.browser.host.should == 'localhost'
    @st.browser.port.should == 4444
  end
end

