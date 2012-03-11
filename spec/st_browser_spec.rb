require 'spec/st_spec_helper'

describe 'browser window' do
  describe "#open_browser" do
    it "raises StopTestCannotConnect if the connection fails" do
      st = Rsel::SeleniumTest.new('bogus_host')
      lambda do
        st.open_browser
      end.should raise_error(Rsel::StopTestCannotConnect)
    end

    # TODO: Find a cross-platform way of testing this
    #it "uses the javascript-xpath library for *iexplore" do
      #st = Rsel::SeleniumTest.new('localhost', :browser => '*iexplore')
      #st.open_browser
    #end

    it "reports failure to connect to a bogus Selenium server" do
      st = Rsel::SeleniumTest.new('http://localhost:8070', { :host => 'localhost', :port => '8070' })
      lambda do
        st.open_browser
      end.should raise_error(Rsel::StopTestCannotConnect)
    end

  end

  describe "#maximize_browser" do
    it "returns true" do
      st = Rsel::SeleniumTest.new('http://localhost:8070')
      st.open_browser
      st.maximize_browser.should be_true
      st.close_browser
    end
  end

  describe "#close_browser" do
    before(:each) do
      @st_temp = Rsel::SeleniumTest.new('http://localhost:8070/')
      @st_temp.open_browser
    end

    it "returns true if there are no errors" do
      @st_temp.close_browser('and show errors').should be_true
    end

    it "returns true if there are errors, but show_errors is unset" do
      @st_temp.field_equals("Nonexistent field", "Nonexistent words")
      @st_temp.close_browser('without showing errors').should be_true
    end

    it "raises StopTestStepFailed if there are errors and show_errors is set" do
      @st_temp.field_equals("Nonexistent field", "Nonexistent words")
      lambda do
        @st_temp.close_browser('and show errors')
      end.should raise_error(Rsel::StopTestStepFailed)
    end
  end
end
