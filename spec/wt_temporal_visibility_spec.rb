require 'spec/wt_spec_helper'

describe 'temporal visibility' do
  describe "#see_within_seconds" do
    before(:each) do
      @wt.visit("/slowtext").should be_true
    end

    context "passes when" do
      it "text is already present" do
        @wt.see("Late text page").should be_true
        @wt.see_within_seconds("The text is coming...", 10).should be_true
      end
      it "text within an id is already present" do
        @wt.see_within_seconds("The text is coming...", 10, :within => 'oldtext').should be_true
      end
      it "text appears in time" do
        @wt.see("The text is coming...").should be_true
        @wt.do_not_see("The text is here!").should be_true
        @wt.see_within_seconds("The text is here!", "10").should be_true
        @wt.see("The text is here!").should be_true
      end
      it "text appears in an id in time" do
        @wt.see("The text is coming...").should be_true
        @wt.do_not_see("The text is here!").should be_true
        @wt.see_within_seconds("The text is here!", "10", :within => 'newtext').should be_true
        @wt.see("The text is here!").should be_true
      end
      it "text appears within default time" do
        @wt.see("The text is coming...").should be_true
        @wt.do_not_see("The text is here!").should be_true
        @wt.see_within_seconds("The text is here!").should be_true
        @wt.see("The text is here!").should be_true
      end
      it "text appears within default time in an id" do
        @wt.see("The text is coming...").should be_true
        @wt.do_not_see("The text is here!").should be_true
        @wt.see_within_seconds("The text is here!", :within => 'newtext').should be_true
        @wt.see("The text is here!").should be_true
      end
    end

    context "fails when" do
      it "text appears too late" do
        @wt.see("The text is coming...").should be_true
        @wt.do_not_see("The text is here!").should be_true
        @wt.see_within_seconds("The text is here!", 1).should be_false
      end
      it "text appears too late in an id" do
        @wt.see_within_seconds("The text is here!", 1, :within => 'newtext').should be_false
      end
      it "text never appears" do
        @wt.see_within_seconds("Nonexistent", 5).should be_false
      end
      it "text never appears in the given id" do
        @wt.see_within_seconds("The text is coming...", 5, :within => 'newtext').should be_false
      end
    end

    it "is case-sensitive" do
      @wt.see_within_seconds("The text is here!", 5).should be_true
      @wt.see_within_seconds("The text IS HERE!", 5).should be_false
    end
  end

  describe "#do_not_see_within_seconds" do
    before(:each) do
      @wt.visit("/slowtext").should be_true
    end

    context "passes when" do
      it "text is already absent" do
        @wt.see("Late text page").should be_true
        @wt.do_not_see_within_seconds("Some absent text", 10).should be_true
      end
      it "text is already absent from the given id" do
        @wt.see("Late text page").should be_true
        @wt.do_not_see_within_seconds("The text is coming...", 10, :within => 'newtext').should be_true
      end
      it "text disappears in time" do
        @wt.see_within_seconds("The text is here!", 10).should be_true
        @wt.do_not_see_within_seconds("The text is here!", "10").should be_true
        @wt.do_not_see("The text is here!").should be_true
      end
      it "text disappears from the given id in time" do
        @wt.see_within_seconds("The text is here!", 10).should be_true
        @wt.do_not_see_within_seconds("The text is here!", "10", :within => 'newtext').should be_true
        @wt.do_not_see("The text is here!").should be_true
      end
      it "text disappears within default time" do
        @wt.see_within_seconds("The text is here!", 10).should be_true
        @wt.do_not_see_within_seconds("The text is here!").should be_true
        @wt.do_not_see("The text is here!").should be_true
      end
      it "text disappears within default time from the given id" do
        @wt.see_within_seconds("The text is here!", 10).should be_true
        @wt.do_not_see_within_seconds("The text is here!", :within => 'newtext').should be_true
        @wt.do_not_see("The text is here!").should be_true
      end
    end

    context "fails when" do
      it "text disappears too late" do
        @wt.see_within_seconds("The text is here!", 10).should be_true
        @wt.do_not_see_within_seconds("The text is here!", 1).should be_false
      end
      it "text disappears too late from an id" do
        @wt.see_within_seconds("The text is here!", 10).should be_true
        @wt.do_not_see_within_seconds("The text is here!", 1, :within => 'newtext').should be_false
      end
      it "text never disappears" do
        @wt.do_not_see_within_seconds("The text is coming...", 5).should be_false
      end
      it "text never disappears from an id" do
        @wt.do_not_see_within_seconds("The text is coming...", 3, :within => 'oldtext').should be_false
      end
    end
  end

end
