require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest, 'initialize' do
  it "sets configuration correctly" do
    @st = Rsel::SeleniumTest.new('http://localhost:8070/')
    @st.url.should == 'http://localhost:8070/'
    @st.browser.host.should == 'localhost'
    @st.browser.port.should == 4444
  end
end


