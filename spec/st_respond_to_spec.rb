require_relative 'st_spec_helper'

describe 'respond_to?' do
  it "returns true if a method is explicitly defined" do
    expect(@st.respond_to?('see')).to be true
  end

  it "returns true if the Selenium::Client::Driver defines the method" do
    expect(@st.respond_to?('is_element_present')).to be true
  end

  it "returns false if the method isn't defined" do
    expect(@st.respond_to?('junk')).to be false
  end
end

