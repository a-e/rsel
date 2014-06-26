require_relative 'st_spec_helper'

describe 'temporal visibility' do
  describe "#see_within_seconds" do
    before(:each) do
      expect(@st.visit("/slowtext")).to be true
    end

    context "passes when" do
      it "text is already present" do
        expect(@st.see("Late text page")).to be true
        expect(@st.see_within_seconds("The text is coming...", 10)).to be true
      end
      it "text within an id is already present" do
        expect(@st.see_within_seconds("The text is coming...", 10, :within => 'oldtext')).to be true
      end
      it "text appears in time" do
        expect(@st.see("The text is coming...")).to be true
        expect(@st.do_not_see("The text is here!")).to be true
        expect(@st.see_within_seconds("The text is here!", "10")).to be true
        expect(@st.see("The text is here!")).to be true
      end
      it "text appears in an id in time" do
        expect(@st.see("The text is coming...")).to be true
        expect(@st.do_not_see("The text is here!")).to be true
        expect(@st.see_within_seconds("The text is here!", "10", :within => 'newtext')).to be true
        expect(@st.see("The text is here!")).to be true
      end
      it "text appears within default time" do
        expect(@st.see("The text is coming...")).to be true
        expect(@st.do_not_see("The text is here!")).to be true
        expect(@st.see_within_seconds("The text is here!")).to be true
        expect(@st.see("The text is here!")).to be true
      end
      it "text appears within default time in an id" do
        expect(@st.see("The text is coming...")).to be true
        expect(@st.do_not_see("The text is here!")).to be true
        expect(@st.see_within_seconds("The text is here!", :within => 'newtext')).to be true
        expect(@st.see("The text is here!")).to be true
      end
    end

    context "fails when" do
      it "text appears too late" do
        expect(@st.see("The text is coming...")).to be true
        expect(@st.do_not_see("The text is here!")).to be true
        expect(@st.see_within_seconds("The text is here!", 1)).to be false
      end
      it "text appears too late in an id" do
        # FIXME: This test occasionally fails for no apparent reason
        # (the text is found within the timeout)
        expect(@st.see_within_seconds("The text is here!", 1, :within => 'newtext')).to be false
      end
      it "text never appears" do
        expect(@st.see_within_seconds("Nonexistent", 5)).to be false
      end
      it "text never appears in the given id" do
        expect(@st.see_within_seconds("The text is coming...", 5, :within => 'newtext')).to be false
      end
    end

    it "is case-sensitive" do
      expect(@st.see_within_seconds("The text is here!", 5)).to be true
      expect(@st.see_within_seconds("The text IS HERE!", 5)).to be false
    end
  end

  describe "#do_not_see_within_seconds" do
    before(:each) do
      expect(@st.visit("/slowtext")).to be true
    end

    context "passes when" do
      it "text is already absent" do
        expect(@st.see("Late text page")).to be true
        expect(@st.do_not_see_within_seconds("Some absent text", 10)).to be true
      end
      it "text is already absent from the given id" do
        expect(@st.see("Late text page")).to be true
        expect(@st.do_not_see_within_seconds("The text is coming...", 10, :within => 'newtext')).to be true
      end
      it "text disappears in time" do
        expect(@st.see_within_seconds("The text is here!", 10)).to be true
        expect(@st.do_not_see_within_seconds("The text is here!", "10")).to be true
        expect(@st.do_not_see("The text is here!")).to be true
      end
      it "text disappears from the given id in time" do
        expect(@st.see_within_seconds("The text is here!", 10)).to be true
        expect(@st.do_not_see_within_seconds("The text is here!", "10", :within => 'newtext')).to be true
        expect(@st.do_not_see("The text is here!")).to be true
      end
      it "text disappears within default time" do
        expect(@st.see_within_seconds("The text is here!", 10)).to be true
        expect(@st.do_not_see_within_seconds("The text is here!")).to be true
        expect(@st.do_not_see("The text is here!")).to be true
      end
      it "text disappears within default time from the given id" do
        expect(@st.see_within_seconds("The text is here!", 10)).to be true
        expect(@st.do_not_see_within_seconds("The text is here!", :within => 'newtext')).to be true
        expect(@st.do_not_see("The text is here!")).to be true
      end
    end

    context "fails when" do
      it "text disappears too late" do
        expect(@st.see_within_seconds("The text is here!", 10)).to be true
        expect(@st.do_not_see_within_seconds("The text is here!", 1)).to be false
      end
      it "text disappears too late from an id" do
        expect(@st.see_within_seconds("The text is here!", 10)).to be true
        expect(@st.do_not_see_within_seconds("The text is here!", 1, :within => 'newtext')).to be false
      end
      it "text never disappears" do
        expect(@st.do_not_see_within_seconds("The text is coming...", 5)).to be false
      end
      it "text never disappears from an id" do
        expect(@st.do_not_see_within_seconds("The text is coming...", 3, :within => 'oldtext')).to be false
      end
    end
  end

end
