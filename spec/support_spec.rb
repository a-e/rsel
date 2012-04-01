require 'spec/spec_helper'

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

    it "requires non-empty element kind for Rsel-style locators" do
      lambda do
        loc('foo')
      end.should raise_error
    end

    it "requires a known element kind for Rsel-style locators" do
      lambda do
        loc('foo', 'bogus_kind')
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
    it "requires a valid, non-empty kind" do
      lambda do
        xpath('junk', 'hello')
      end.should raise_error

      lambda do
        xpath('', 'hello')
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

  describe "#string_is_true?" do
    it "returns true for true strings" do
      ["", "1", "check", "checked", "on", "select", "selected", "true", "yes"].each do |s|
        string_is_true?(s).should be_true
      end
    end
    it "is case-insensitive" do
      ["Check", "Checked", "On", "Select", "Selected", "True", "Yes"].each do |s|
        string_is_true?(s).should be_true
      end
    end
    it "returns false for other strings" do
      ["False", "WRONG!", "NoNSEnSe$%$@^@!^!%", "0", "null"].each do |s|
        string_is_true?(s).should be_false
      end
    end
  end

  describe "#selenium_compare" do
    context "returns true when" do
      it "gets most identical strings" do
        selenium_compare("", "").should be_true
        selenium_compare("This", "This").should be_true
      end
      it "gets exact:ly identical strings" do
        selenium_compare("", "exact:").should be_true
        selenium_compare("This", "exact:This").should be_true
      end
      it "gets matching globs" do
        selenium_compare("", "*").should be_true
        selenium_compare("anything", "*").should be_true
        selenium_compare("Neffing", "Nef*").should be_true
      end
      it "gets matching labeled globs" do
        selenium_compare("", "glob:*").should be_true
        selenium_compare("anything", "glob:*").should be_true
        selenium_compare("Neffing", "glob:Nef*").should be_true
      end
      it "gets matching regexes" do
        selenium_compare("", "regexp:.*").should be_true
        selenium_compare("anything", "regexp:.*").should be_true
        selenium_compare("Neffing", "regexp:^Nef[a-z]*$").should be_true
      end
      it "gets matching case-insensitive regexes" do
        selenium_compare("", "regexpi:.*").should be_true
        selenium_compare("Neffing", "regexpi:^nef[A-Z]*$").should be_true
      end
    end

    context "returns false when" do
      it "gets most differing strings" do
        selenium_compare("", "!").should be_false
        selenium_compare("&", "").should be_false
        selenium_compare("This", "That").should be_false
      end
      it "gets exact:ly different strings" do
        selenium_compare("", "exact:!").should be_false
        selenium_compare("!!", "exact:!").should be_false
        selenium_compare("&", "exact:").should be_false
        selenium_compare("This", "exact:That").should be_false
      end
      it "gets non-matching globs" do
        selenium_compare("No", "?").should be_false
        selenium_compare("Netting", "Nef*").should be_false
      end
      it "gets non-matching labeled globs" do
        selenium_compare("No", "glob:?").should be_false
        selenium_compare("Netting", "glob:Nef*").should be_false
      end
      it "gets non-matching regexes" do
        selenium_compare("1", "regexp:^[a-z]*$").should be_false
        selenium_compare("Netting", "regexp:^Nef[a-z]*$").should be_false
        selenium_compare("Neffing", "regexp:^nef[A-Z]*$").should be_false
      end
      it "gets non-matching case-insensitive regexes" do
        selenium_compare("1", "regexpi:^[a-z]*$").should be_false
        selenium_compare("Netting", "regexpi:^nef[A-Z]*$").should be_false
      end
    end
  end

  describe "#xpath_sanitize" do
    it "escapes one single-quote" do
      result = xpath_sanitize("Bob's water")
      result.should == %Q{concat('Bob', "'", 's water')}
    end

    it "escapes two single-quotes" do
      result = xpath_sanitize("Bob's on the water's edge")
      result.should == %Q{concat('Bob', "'", 's on the water', "'", 's edge')}
    end

    it "leaves strings without single-quotes alone" do
      result = xpath_sanitize("bobs in the water")
      result.should == %Q{'bobs in the water'}
    end
  end

  describe "#xpath_row_containing" do
    it "returns an XPath for a table row containing multiple strings" do
      result = xpath_row_containing(['abc', 'def'])
      result.should == %Q{//tr[contains(., 'abc') and contains(., 'def')]}
    end
  end

  describe "#result_within" do
    context "returns the result when" do
      it "block evaluates to true immediately" do
        result_within(3) do
          true
        end.should == true
      end

      it "block evaluates to a non-false value immediately" do
        result_within(3) do
          foo = 'foo'
        end.should == 'foo'
      end

      it "block evaluates to false initially, but true within the timeout" do
        @first_run = true
        result_within(3) do
          if @first_run
            @first_run = false
            false
          else
            true
          end
        end.should == true
      end

      it "block raises an exception, but evaluates true within the timeout" do
        @first_run = true
        result_within(3) do
          if @first_run
            @first_run = false
            raise RuntimeError
          else
            true
          end
        end.should == true
      end
    end

    context "returns false when" do
      it "block evaluates as false every time" do
        result_within(3) do
          false
        end.should be_nil
      end

      it "block evaluates as nil every time" do
        result_within(3) do
          nil
        end.should be_nil
      end

      it "block raises an exception every time" do
        result_within(3) do
          raise RuntimeError
        end.should be_nil
      end

      it "block does not return within the timeout"
    end
  end
end

