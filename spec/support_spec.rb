require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

require 'xpath'

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

    it "accepts within for css locators" do
      loc("css=.boss", '', {:within => "employees"}).should == "css=#employees .boss"
    end

    it "accepts in_row for css locators" do
      loc("css=td.salary", '', {:in_row => "Eric"}).should == "css=tr:contains(\"Eric\") td.salary"
    end
  end

  describe "#xpath" do
    it "requires a valid kind" do
      lambda do
        xpath('junk', 'hello')
      end.should raise_error
    end

    it "applies within scope" do
      # Quick-and-dirty: Just ensure the scoping phrase appears in the xpath
      xpath('link', 'Edit', :within => '#first_div').should include('#first_div')
    end

    it "applies in_row scope" do
      # Quick-and-dirty: Just ensure the scoping phrase appears in the xpath
      xpath('link', 'Edit', :in_row => 'Eric').should include('Eric')
    end
  end

  describe "#escape_for_hash" do
    context "escapes when" do
      it "escapes semicolon to colon" do
        escape_for_hash('\\' + ";").should == ":"
      end

      it "escapes single-quote to comma" do
        escape_for_hash('\\' + "'").should == ","
      end

      it "escapes left-bracket to left-brace" do
        escape_for_hash('\\' + "[").should == "{"
      end

      it "escapes right-bracket to right-brace" do
        escape_for_hash('\\' + "]").should == "}"
      end

      it "escapes backslash" do
        escape_for_hash('\\\\').should == '\\'
      end

      it "handles a DOS path" do
        escape_for_hash('c\\;\\*.bat').should == 'c:\\*.bat'
      end
    end

    context "does not escape when" do
      it "sees a lone semicolon" do
        escape_for_hash(";").should == ";"
      end

      it "sees a lone single-quote" do
        escape_for_hash("'").should == "'"
      end

      it "sees a lone left-bracket" do
        escape_for_hash("[").should == "["
      end

      it "sees a lone right-bracket" do
        escape_for_hash("]").should == "]"
      end

      it "sees a backslash before semicolon" do
        escape_for_hash('\\\\' + ";").should == "\\;"
      end

      it "sees a backslash before single-quote" do
        escape_for_hash('\\\\' + "'").should == "\\'"
      end

      it "sees a backslash before left-bracket" do
        escape_for_hash('\\\\' + "[").should == "\\["
      end

      it "sees a backslash before right-bracket" do
        escape_for_hash('\\\\' + "]").should == "\\]"
      end

      it "handles a single backslash" do
        escape_for_hash('\\').should == '\\'
      end
    end

  end

  describe "#normalize_ids" do
    it "converts keys to lowercase" do
      ids = {
        "First Name" => "Eric",
        "PIN" => "123",
      }
      normalize_ids(ids)
      ids.should == {
        "first name" => "Eric",
        "pin" => "123",
      }
    end

    it "escapes all keys using #escape_for_hash" do
      ids = {
        'with\[brackets\]' => 'Foo',
      }
      normalize_ids(ids)
      ids.should == {
        'with{brackets}' => 'Foo',
      }
    end

    it "escapes values but leaves case alone" do
      ids = {
        'foo' => 'with\;colon',
      }
      normalize_ids(ids)
      ids.should == {
        'foo' => 'with:colon',
      }
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

  describe "#xpath_expressions" do
    it "breaks down XPath::Union into XPath::Expressions" do
      foo = XPath::HTML.option('foo')
      bar = XPath::HTML.option('bar')
      baz = XPath::HTML.option('baz')
      union = XPath::Union.new(foo, bar, baz)
      xpath_expressions(union).should == [foo, bar, baz]
    end

    it "returns [expr] for a single XPath::Expression" do
      foo = XPath::HTML.option('foo')
      xpath_expressions(foo).should == [foo]
    end
  end

  describe "#apply_scope" do
    it "returns an xpath string with one element scoped inside another" do
      row = XPath::HTML.send('table_row', 'foo')
      link = XPath::HTML.send('link', 'bar')
      union = XPath::Union.new(row.child(link))
      apply_scope(row, link).should == union.to_s
    end
  end
end

