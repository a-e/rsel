require_relative 'st_spec_helper'

describe 'conditionals' do
  before(:each) do
    @st.visit("/").should be true
    @st.reset_conditionals
  end

  describe "#if_i_see" do
    context "passes when" do
      it "sees text" do
        @st.if_i_see("About this site").should be true
        @st.click("About this site").should be true
        @st.end_if.should be true
      end

      it "is inside a passed block" do
        @st.if_i_see("About this site").should be true
        @st.click("About this site").should be true
        @st.page_loads_in_seconds_or_less(10).should be true
        @st.if_i_see("This site is").should be true
        @st.see("is really cool.").should be true
        @st.end_if.should be true
        @st.end_if.should be true
      end
    end

    context "skips when" do
      it "does not see text" do
        @st.if_i_see("Bogus link").should be_nil
        @st.click("Bogus link").should be_nil
        @st.end_if.should be true
      end

      it "is inside a skipped block" do
        @st.if_i_see("Bogus link").should be_nil
        @st.click("Bogus link").should be_nil
        @st.if_i_see("About this site").should be_nil
        @st.click("About this site").should be_nil
        @st.end_if.should be_nil
        @st.end_if.should be true
      end
    end
  end

  describe "#if_parameter" do
    context "passes when" do
      it "sees yes" do
        @st.if_parameter("yes").should be true
        @st.click("About this site").should be true
        @st.end_if.should be true
      end

      it "sees true" do
        @st.if_parameter("true").should be true
        @st.click("About this site").should be true
        @st.end_if.should be true
      end

      it "sees YES" do
        @st.if_parameter("YES").should be true
        @st.click("About this site").should be true
        @st.end_if.should be true
      end

      it "sees TRUE" do
        @st.if_parameter("TRUE").should be true
        @st.click("About this site").should be true
        @st.end_if.should be true
      end

      it "is inside a passed block" do
        @st.if_i_see("About this site").should be true
        @st.click("About this site").should be true
        @st.page_loads_in_seconds_or_less(10).should be true
        @st.if_parameter("True").should be true
        @st.see("is really cool.").should be true
        @st.end_if.should be true
        @st.end_if.should be true
      end
    end

    context "skips when" do
      it "sees something other than yes or true" do
        @st.if_parameter("Bogus").should be_nil
        @st.click("Bogus link").should be_nil
        @st.end_if.should be true
      end

      it "is inside a skipped block" do
        @st.if_parameter("Bogus link").should be_nil
        @st.click("Bogus link").should be_nil
        @st.if_parameter("TRUE").should be_nil
        @st.click("About this site").should be_nil
        @st.end_if.should be_nil
        @st.end_if.should be true
      end
    end
  end

  # TODO: if_is
  describe "#if_is" do
    context "passes when" do
      it "sees the same string" do
        @st.if_is("yes", 'yes').should be true
        @st.click("About this site").should be true
        @st.end_if.should be true
      end

      it "sees a matching empty string" do
        @st.if_is("",'').should be true
        @st.click("About this site").should be true
        @st.end_if.should be true
      end

      it "is inside a passed block" do
        @st.if_i_see("About this site").should be true
        @st.click("About this site").should be true
        @st.page_loads_in_seconds_or_less(10).should be true
        @st.if_is("True", "True").should be true
        @st.see("is really cool.").should be true
        @st.end_if.should be true
        @st.end_if.should be true
      end
    end

    context "skips when" do
      it "sees different strings" do
        @st.if_is("Ken", "Bogus").should be_nil
        @st.click("Bogus link").should be_nil
        @st.end_if.should be true
      end

      it "is inside a skipped block" do
        @st.if_is("Ken", "Bogus").should be_nil
        @st.click("Bogus link").should be_nil
        @st.if_is("True", "True").should be_nil
        @st.click("About this site").should be_nil
        @st.end_if.should be_nil
        @st.end_if.should be true
      end
    end
  end

  describe "#otherwise" do
    context "skips when" do
      it "its if was true" do
        @st.if_i_see("About this site").should be true
        @st.click("About this site").should be true
        @st.otherwise.should be_nil
        @st.click("Bogus link").should be_nil
        @st.end_if.should be true
      end
    end
    context "passes when" do
      it "its if was false" do
        @st.if_i_see("Bogus link").should be_nil
        @st.click("Bogus link").should be_nil
        @st.otherwise.should be true
        @st.click("About this site").should be true
        @st.end_if.should be true
      end
    end

    context "fails when" do
      it "does not have a matching if" do
        @st.otherwise.should be false
      end
    end
  end

  describe "#end_if" do
    context "fails when" do
      it "does not have a matching if" do
        @st.end_if.should be false
      end
    end
  end

end
