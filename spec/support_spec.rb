require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Rsel::Support do
  describe "#loc" do
    it "returns Selenium-style locators unchanged" do
      locators = [
        "id=foo_bar",
        "name=foo_bar",
        "xpath=//input[@id='foo_bar']",
        "css=div#foo_bar",
      ]
      locators.each do |locator|
        loc(locator).should == locator
      end
    end

    it "returns Rsel-style locators as Selenium xpaths" do
      locators = [
        "First name",
        "first_name",
      ]
      locators.each do |locator|
        loc(locator, 'field').should =~ /^xpath=/
      end
    end

    it "requires a non-empty locator" do
      lambda do
        loc('')
      end.should raise_error
    end

    it "requires element kind for Rsel-style locators" do
      lambda do
        loc('foo')
      end.should raise_error
    end
  end

  describe "#xpath" do
    it "requires a valid kind" do
      lambda do
        xpath('junk', 'hello')
      end.should raise_error
    end
  end

  describe "#strip_tags" do
    it "strips anchor tags from links" do
      html = '<a href="http://example.com/">http://example.com</a>'
      strip_tags(html).should == 'http://example.com'
    end

    it "leaves plain text alone" do
      html = 'http://example.com'
      strip_tags(html).should == 'http://example.com'
    end
  end
end

