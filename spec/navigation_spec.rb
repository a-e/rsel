require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest do
  before(:each) do
  end

  context "opens and closes the browser" do
    @st = Rsel::SeleniumTest.new('http://localhost:8070/home')
    @st.open_browser
  end
end

