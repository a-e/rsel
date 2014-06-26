require_relative 'wt_spec_helper'

describe 'respond_to?' do
  it "returns true if a method is explicitly defined" do
    @wt.respond_to?('see').should == true
  end

  it "returns true if the Selenium::Client::Driver defines the method" do
    @wt.respond_to?('is_element_present').should == true
  end

  it "returns false if the method isn't defined" do
    @wt.respond_to?('junk').should == false
  end
end

