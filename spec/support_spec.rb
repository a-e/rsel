require_relative 'spec_helper'

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
        expect(loc(locator)).to eq locator
      end
    end

    it "returns Rsel-style locators as Selenium xpaths" do
      locators = [
        "First name",
        "first_name",
      ]
      locators.each do |locator|
        expect(loc(locator, 'field')).to match(/^xpath=/)
      end
    end

    it "requires a non-empty locator" do
      expect { loc('') }.to raise_error
    end

    it "requires non-empty element kind for Rsel-style locators" do
      expect { loc('foo') }.to raise_error
    end

    it "requires a known element kind for Rsel-style locators" do
      expect { loc('foo', 'bogus_kind') }.to raise_error
    end

    it "accepts within for css locators" do
      expect(loc("css=.boss", '', {:within => "employees"})).to eq "css=#employees .boss"
    end

    it "accepts in_row for css locators" do
      expect(loc("css=td.salary", '', {:in_row => "Eric"})).to eq "css=tr:contains(\"Eric\") td.salary"
    end
  end

  describe "#xpath" do
    it "requires a valid, non-empty kind" do
      expect { xpath('junk', 'hello') }.to raise_error

      expect { xpath('', 'hello') }.to raise_error
    end

    it "applies within scope" do
      # Quick-and-dirty: Just ensure the scoping phrase appears in the xpath
      expect(xpath('link', 'Edit', :within => '#first_div')).to include('#first_div')
    end

    it "applies in_row scope" do
      # Quick-and-dirty: Just ensure the scoping phrase appears in the xpath
      expect(xpath('link', 'Edit', :in_row => 'Eric')).to include('Eric')
    end
  end

  describe "#escape_for_hash" do
    context "escapes when" do
      it "escapes semicolon to colon" do
        expect(escape_for_hash('\\' + ";")).to eq ":"
      end

      it "escapes single-quote to comma" do
        expect(escape_for_hash('\\' + "'")).to eq ","
      end

      it "escapes left-bracket to left-brace" do
        expect(escape_for_hash('\\' + "[")).to eq "{"
      end

      it "escapes right-bracket to right-brace" do
        expect(escape_for_hash('\\' + "]")).to eq "}"
      end

      it "escapes backslash" do
        expect(escape_for_hash('\\\\')).to eq '\\'
      end

      it "handles a DOS path" do
        expect(escape_for_hash('c\\;\\*.bat')).to eq 'c:\\*.bat'
      end
    end

    context "does not escape when" do
      it "sees a lone semicolon" do
        expect(escape_for_hash(";")).to eq ";"
      end

      it "sees a lone single-quote" do
        expect(escape_for_hash("'")).to eq "'"
      end

      it "sees a lone left-bracket" do
        expect(escape_for_hash("[")).to eq "["
      end

      it "sees a lone right-bracket" do
        expect(escape_for_hash("]")).to eq "]"
      end

      it "sees a backslash before semicolon" do
        expect(escape_for_hash('\\\\' + ";")).to eq "\\;"
      end

      it "sees a backslash before single-quote" do
        expect(escape_for_hash('\\\\' + "'")).to eq "\\'"
      end

      it "sees a backslash before left-bracket" do
        expect(escape_for_hash('\\\\' + "[")).to eq "\\["
      end

      it "sees a backslash before right-bracket" do
        expect(escape_for_hash('\\\\' + "]")).to eq "\\]"
      end

      it "handles a single backslash" do
        expect(escape_for_hash('\\')).to eq '\\'
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
      expect(ids).to eq({
        "first name" => "Eric",
        "pin" => "123",
      })
    end

    it "escapes all keys using #escape_for_hash" do
      ids = {
        'with\[brackets\]' => 'Foo',
      }
      normalize_ids(ids)
      expect(ids).to eq({
        'with{brackets}' => 'Foo',
      })
    end

    it "escapes values but leaves case alone" do
      ids = {
        'foo' => 'with\;colon',
      }
      normalize_ids(ids)
      expect(ids).to eq({
        'foo' => 'with:colon',
      })
    end
  end

  describe "#strip_tags" do
    it "strips anchor tags from links" do
      html = '<a href="http://example.com/">http://example.com</a>'
      expect(strip_tags(html)).to eq 'http://example.com'
    end

    it "leaves plain text alone" do
      html = 'http://example.com'
      expect(strip_tags(html)).to eq 'http://example.com'
    end
  end

  describe "#xpath_expressions" do
    it "breaks down XPath::Union into XPath::Expressions" do
      foo = XPath::HTML.option('foo')
      bar = XPath::HTML.option('bar')
      baz = XPath::HTML.option('baz')
      union = XPath::Union.new(foo, bar, baz)
      expect(xpath_expressions(union)).to eq [foo, bar, baz]
    end

    it "returns [expr] for a single XPath::Expression" do
      foo = XPath::HTML.option('foo')
      expect(xpath_expressions(foo)).to eq [foo]
    end
  end

  describe "#apply_scope" do
    it "returns an xpath string with one element scoped inside another" do
      row = XPath::HTML.send('table_row', 'foo')
      link = XPath::HTML.send('link', 'bar')
      union = XPath::Union.new(row.child(link))
      expect(apply_scope(row, link)).to eq union.to_s
    end
  end

  describe "#string_is_true?" do
    it "returns true for true strings" do
      ["", "1", "check", "checked", "on", "select", "selected", "true", "yes"].each do |s|
        expect(string_is_true?(s)).to be true
      end
    end
    it "is case-insensitive" do
      ["Check", "Checked", "On", "Select", "Selected", "True", "Yes"].each do |s|
        expect(string_is_true?(s)).to be true
      end
    end
    it "returns false for other strings" do
      ["False", "WRONG!", "NoNSEnSe$%$@^@!^!%", "0", "null"].each do |s|
        expect(string_is_true?(s)).to be false
      end
    end
  end

  describe "#selenium_compare" do
    context "returns true when" do
      it "gets most identical strings" do
        expect(selenium_compare("", "")).to be true
        expect(selenium_compare("This", "This")).to be true
      end
      it "gets exact:ly identical strings" do
        expect(selenium_compare("", "exact:")).to be true
        expect(selenium_compare("This", "exact:This")).to be true
      end
      it "gets matching globs" do
        expect(selenium_compare("", "*")).to be true
        expect(selenium_compare("anything", "*")).to be true
        expect(selenium_compare("Neffing", "Nef*")).to be true
      end
      it "gets matching labeled globs" do
        expect(selenium_compare("", "glob:*")).to be true
        expect(selenium_compare("anything", "glob:*")).to be true
        expect(selenium_compare("Neffing", "glob:Nef*")).to be true
      end
      it "gets matching regexes" do
        expect(selenium_compare("", "regexp:.*")).to be true
        expect(selenium_compare("anything", "regexp:.*")).to be true
        expect(selenium_compare("Neffing", "regexp:^Nef[a-z]*$")).to be true
      end
      it "gets matching case-insensitive regexes" do
        expect(selenium_compare("", "regexpi:.*")).to be true
        expect(selenium_compare("Neffing", "regexpi:^nef[A-Z]*$")).to be true
      end
    end

    context "returns false when" do
      it "gets most differing strings" do
        expect(selenium_compare("", "!")).to be false
        expect(selenium_compare("&", "")).to be false
        expect(selenium_compare("This", "That")).to be false
      end
      it "gets exact:ly different strings" do
        expect(selenium_compare("", "exact:!")).to be false
        expect(selenium_compare("!!", "exact:!")).to be false
        expect(selenium_compare("&", "exact:")).to be false
        expect(selenium_compare("This", "exact:That")).to be false
      end
      it "gets non-matching globs" do
        expect(selenium_compare("No", "?")).to be false
        expect(selenium_compare("Netting", "Nef*")).to be false
      end
      it "gets non-matching labeled globs" do
        expect(selenium_compare("No", "glob:?")).to be false
        expect(selenium_compare("Netting", "glob:Nef*")).to be false
      end
      it "gets non-matching regexes" do
        expect(selenium_compare("1", "regexp:^[a-z]*$")).to be false
        expect(selenium_compare("Netting", "regexp:^Nef[a-z]*$")).to be false
        expect(selenium_compare("Neffing", "regexp:^nef[A-Z]*$")).to be false
      end
      it "gets non-matching case-insensitive regexes" do
        expect(selenium_compare("1", "regexpi:^[a-z]*$")).to be false
        expect(selenium_compare("Netting", "regexpi:^nef[A-Z]*$")).to be false
      end
    end
  end

  describe "#xpath_sanitize" do
    it "escapes one single-quote" do
      result = xpath_sanitize("Bob's water")
      expect(result).to eq %Q{concat('Bob', "'", 's water')}
    end

    it "escapes two single-quotes" do
      result = xpath_sanitize("Bob's on the water's edge")
      expect(result).to eq %Q{concat('Bob', "'", 's on the water', "'", 's edge')}
    end

    it "leaves strings without single-quotes alone" do
      result = xpath_sanitize("bobs in the water")
      expect(result).to eq %Q{'bobs in the water'}
    end
  end

  describe "#xpath_row_containing" do
    it "returns an XPath for a table row containing multiple strings" do
      result = xpath_row_containing(['abc', 'def'])
      expect(result).to eq %Q{//tr[contains(., 'abc') and contains(., 'def')]}
    end
  end

  describe "#globify" do
    it "leaves `exact:text` unchanged" do
      expect(globify('exact:text')).to eq 'exact:text'
    end

    it "leaves `regexp:text` unchanged" do
      expect(globify('regexp:text')).to eq 'regexp:text'
    end

    it "leaves `regexpi:text` unchanged" do
      expect(globify('regexpi:text')).to eq 'regexpi:text'
    end

    it "converts `glob:text` to `*text*`" do
      expect(globify('glob:text')).to eq '*text*'
    end

    it "adds *...* to text" do
      expect(globify('text')).to eq '*text*'
    end
  end

end

