require_relative 'st_spec_helper'

describe 'initialization' do
  it "sets correct default configuration" do
    st = Rsel::SeleniumTest.new('http://some.host.org:8070/')
    expect(st.url).to eq "http://some.host.org:8070/"
    # Defaults
    expect(st.browser.host).to eq "localhost"
    expect(st.browser.port).to eq 4444
    expect(st.browser.browser_string).to eq "*firefox"
    expect(st.browser.default_timeout_in_seconds).to eq 300
    expect(st.stop_on_failure).to eq false
    expect(st.found_failure).to eq false
  end

  context "stop_on_failure option" do
    it "can be initialized with a string" do
      st = Rsel::SeleniumTest.new('localhost', :stop_on_failure => 'true')
      expect(st.stop_on_failure).to be true
      st = Rsel::SeleniumTest.new('localhost', :stop_on_failure => 'FALSE')
      expect(st.stop_on_failure).to be false
    end

    it "can be initialized with a boolean" do
      st = Rsel::SeleniumTest.new('localhost', :stop_on_failure => true)
      expect(st.stop_on_failure).to be true
      st = Rsel::SeleniumTest.new('localhost', :stop_on_failure => false)
      expect(st.stop_on_failure).to be false
    end
  end

end

