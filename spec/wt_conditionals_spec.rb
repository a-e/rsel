require_relative 'wt_spec_helper'

describe 'conditionals' do
  before(:each) do
    @wt.visit("/").should be_true
    @wt.reset_conditionals
  end

  describe "#if_i_see" do
    context "passes when" do
      it "sees text" do
        @wt.if_i_see("About this site").should be_true
        @wt.click("About this site").should be_true
        @wt.end_if.should be_true
      end

      it "is inside a passed block" do
        @wt.if_i_see("About this site").should be_true
        @wt.click("About this site").should be_true
        @wt.page_loads_in_seconds_or_less(10).should be_true
        @wt.if_i_see("This site is").should be_true
        @wt.see("is really cool.").should be_true
        @wt.end_if.should be_true
        @wt.end_if.should be_true
      end
    end

    context "skips when" do
      it "does not see text" do
        @wt.if_i_see("Bogus link").should be_nil
        @wt.click("Bogus link").should be_nil
        @wt.end_if.should be_true
      end

      it "is inside a skipped block" do
        @wt.if_i_see("Bogus link").should be_nil
        @wt.click("Bogus link").should be_nil
        @wt.if_i_see("About this site").should be_nil
        @wt.click("About this site").should be_nil
        @wt.end_if.should be_nil
        @wt.end_if.should be_true
      end
    end
  end

  describe "#if_parameter" do
    context "passes when" do
      it "sees yes" do
        @wt.if_parameter("yes").should be_true
        @wt.click("About this site").should be_true
        @wt.end_if.should be_true
      end

      it "sees true" do
        @wt.if_parameter("true").should be_true
        @wt.click("About this site").should be_true
        @wt.end_if.should be_true
      end

      it "sees YES" do
        @wt.if_parameter("YES").should be_true
        @wt.click("About this site").should be_true
        @wt.end_if.should be_true
      end

      it "sees TRUE" do
        @wt.if_parameter("TRUE").should be_true
        @wt.click("About this site").should be_true
        @wt.end_if.should be_true
      end

      it "is inside a passed block" do
        @wt.if_i_see("About this site").should be_true
        @wt.click("About this site").should be_true
        @wt.page_loads_in_seconds_or_less(10).should be_true
        @wt.if_parameter("True").should be_true
        @wt.see("is really cool.").should be_true
        @wt.end_if.should be_true
        @wt.end_if.should be_true
      end
    end

    context "skips when" do
      it "sees something other than yes or true" do
        @wt.if_parameter("Bogus").should be_nil
        @wt.click("Bogus link").should be_nil
        @wt.end_if.should be_true
      end

      it "is inside a skipped block" do
        @wt.if_parameter("Bogus link").should be_nil
        @wt.click("Bogus link").should be_nil
        @wt.if_parameter("TRUE").should be_nil
        @wt.click("About this site").should be_nil
        @wt.end_if.should be_nil
        @wt.end_if.should be_true
      end
    end
  end

  # TODO: if_is
  describe "#if_is" do
    context "passes when" do
      it "sees the same string" do
        @wt.if_is("yes", 'yes').should be_true
        @wt.click("About this site").should be_true
        @wt.end_if.should be_true
      end

      it "sees a matching empty string" do
        @wt.if_is("",'').should be_true
        @wt.click("About this site").should be_true
        @wt.end_if.should be_true
      end

      it "is inside a passed block" do
        @wt.if_i_see("About this site").should be_true
        @wt.click("About this site").should be_true
        @wt.page_loads_in_seconds_or_less(10).should be_true
        @wt.if_is("True", "True").should be_true
        @wt.see("is really cool.").should be_true
        @wt.end_if.should be_true
        @wt.end_if.should be_true
      end
    end

    context "skips when" do
      it "sees different strings" do
        @wt.if_is("Ken", "Bogus").should be_nil
        @wt.click("Bogus link").should be_nil
        @wt.end_if.should be_true
      end

      it "is inside a skipped block" do
        @wt.if_is("Ken", "Bogus").should be_nil
        @wt.click("Bogus link").should be_nil
        @wt.if_is("True", "True").should be_nil
        @wt.click("About this site").should be_nil
        @wt.end_if.should be_nil
        @wt.end_if.should be_true
      end
    end
  end

  describe "#otherwise" do
    context "skips when" do
      it "its if was true" do
        @wt.if_i_see("About this site").should be_true
        @wt.click("About this site").should be_true
        @wt.otherwise.should be_nil
        @wt.click("Bogus link").should be_nil
        @wt.end_if.should be_true
      end
    end
    context "passes when" do
      it "its if was false" do
        @wt.if_i_see("Bogus link").should be_nil
        @wt.click("Bogus link").should be_nil
        @wt.otherwise.should be_true
        @wt.click("About this site").should be_true
        @wt.end_if.should be_true
      end
    end

    context "fails when" do
      it "does not have a matching if" do
        @wt.otherwise.should be_false
      end
    end
  end

  describe "#end_if" do
    context "fails when" do
      it "does not have a matching if" do
        @wt.end_if.should be_false
      end
    end
  end

end
