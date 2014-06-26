require_relative 'st_spec_helper'

describe 'conditionals' do
  before(:each) do
    expect(@st.visit("/")).to be true
    @st.reset_conditionals
  end

  describe "#if_i_see" do
    context "passes when" do
      it "sees text" do
        expect(@st.if_i_see("About this site")).to be true
        expect(@st.click("About this site")).to be true
        @st.end_if.should be true
      end

      it "is inside a passed block" do
        expect(@st.if_i_see("About this site")).to be true
        expect(@st.click("About this site")).to be true
        expect(@st.page_loads_in_seconds_or_less(10)).to be true
        expect(@st.if_i_see("This site is")).to be true
        expect(@st.see("is really cool.")).to be true
        @st.end_if.should be true
        @st.end_if.should be true
      end
    end

    context "skips when" do
      it "does not see text" do
        expect(@st.if_i_see("Bogus link")).to be_nil
        expect(@st.click("Bogus link")).to be_nil
        @st.end_if.should be true
      end

      it "is inside a skipped block" do
        expect(@st.if_i_see("Bogus link")).to be_nil
        expect(@st.click("Bogus link")).to be_nil
        expect(@st.if_i_see("About this site")).to be_nil
        expect(@st.click("About this site")).to be_nil
        @st.end_if.should be_nil
        @st.end_if.should be true
      end
    end
  end

  describe "#if_parameter" do
    context "passes when" do
      it "sees yes" do
        expect(@st.if_parameter("yes")).to be true
        expect(@st.click("About this site")).to be true
        @st.end_if.should be true
      end

      it "sees true" do
        expect(@st.if_parameter("true")).to be true
        expect(@st.click("About this site")).to be true
        @st.end_if.should be true
      end

      it "sees YES" do
        expect(@st.if_parameter("YES")).to be true
        expect(@st.click("About this site")).to be true
        @st.end_if.should be true
      end

      it "sees TRUE" do
        expect(@st.if_parameter("TRUE")).to be true
        expect(@st.click("About this site")).to be true
        @st.end_if.should be true
      end

      it "is inside a passed block" do
        expect(@st.if_i_see("About this site")).to be true
        expect(@st.click("About this site")).to be true
        expect(@st.page_loads_in_seconds_or_less(10)).to be true
        expect(@st.if_parameter("True")).to be true
        expect(@st.see("is really cool.")).to be true
        @st.end_if.should be true
        @st.end_if.should be true
      end
    end

    context "skips when" do
      it "sees something other than yes or true" do
        expect(@st.if_parameter("Bogus")).to be_nil
        expect(@st.click("Bogus link")).to be_nil
        @st.end_if.should be true
      end

      it "is inside a skipped block" do
        expect(@st.if_parameter("Bogus link")).to be_nil
        expect(@st.click("Bogus link")).to be_nil
        expect(@st.if_parameter("TRUE")).to be_nil
        expect(@st.click("About this site")).to be_nil
        @st.end_if.should be_nil
        @st.end_if.should be true
      end
    end
  end

  # TODO: if_is
  describe "#if_is" do
    context "passes when" do
      it "sees the same string" do
        expect(@st.if_is("yes", 'yes')).to be true
        expect(@st.click("About this site")).to be true
        @st.end_if.should be true
      end

      it "sees a matching empty string" do
        expect(@st.if_is("",'')).to be true
        expect(@st.click("About this site")).to be true
        @st.end_if.should be true
      end

      it "is inside a passed block" do
        expect(@st.if_i_see("About this site")).to be true
        expect(@st.click("About this site")).to be true
        expect(@st.page_loads_in_seconds_or_less(10)).to be true
        expect(@st.if_is("True", "True")).to be true
        expect(@st.see("is really cool.")).to be true
        @st.end_if.should be true
        @st.end_if.should be true
      end
    end

    context "skips when" do
      it "sees different strings" do
        expect(@st.if_is("Ken", "Bogus")).to be_nil
        expect(@st.click("Bogus link")).to be_nil
        @st.end_if.should be true
      end

      it "is inside a skipped block" do
        expect(@st.if_is("Ken", "Bogus")).to be_nil
        expect(@st.click("Bogus link")).to be_nil
        expect(@st.if_is("True", "True")).to be_nil
        expect(@st.click("About this site")).to be_nil
        @st.end_if.should be_nil
        @st.end_if.should be true
      end
    end
  end

  describe "#otherwise" do
    context "skips when" do
      it "its if was true" do
        expect(@st.if_i_see("About this site")).to be true
        expect(@st.click("About this site")).to be true
        @st.otherwise.should be_nil
        expect(@st.click("Bogus link")).to be_nil
        @st.end_if.should be true
      end
    end
    context "passes when" do
      it "its if was false" do
        expect(@st.if_i_see("Bogus link")).to be_nil
        expect(@st.click("Bogus link")).to be_nil
        @st.otherwise.should be true
        expect(@st.click("About this site")).to be true
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
