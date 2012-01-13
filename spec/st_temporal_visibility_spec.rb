require 'spec/spec_helper'

describe 'temporal visibility' do
  before(:each) do
    @st.visit("/slowtext").should be_true
  end

  describe "#see_within_seconds" do
    context "passes when" do
      it "text is already present" do
        @st.see("Late text page").should be_true
        @st.see_within_seconds("The text is coming...", 10).should be_true
      end
      it "text appears in time" do
        @st.see("The text is coming...").should be_true
        @st.do_not_see("The text is here!").should be_true
        @st.see_within_seconds("The text is here!", "10").should be_true
        @st.see("The text is here!").should be_true
      end
      it "text appears within default time" do
        @st.see("The text is coming...").should be_true
        @st.do_not_see("The text is here!").should be_true
        @st.see_within_seconds("The text is here!").should be_true
        @st.see("The text is here!").should be_true
      end
    end

    context "fails when" do
      it "text appears too late" do
        @st.see("The text is coming...").should be_true
        @st.do_not_see("The text is here!").should be_true
        @st.see_within_seconds("The text is here!", 1).should be_false
      end
      it "text never appears" do
        @st.see_within_seconds("Nonexistent", 5).should be_false
      end
    end

    it "is case-sensitive" do
      @st.see_within_seconds("The text is here!", 5).should be_true
      @st.see_within_seconds("The text IS HERE!", 5).should be_false
    end
  end

  describe "#do_not_see_within_seconds" do
    context "passes when" do
      it "text is already absent" do
        @st.see("Late text page").should be_true
        @st.do_not_see_within_seconds("Some absent text", 10).should be_true
      end
      it "text disappears in time" do
        @st.see_within_seconds("The text is here!", 10).should be_true
        @st.do_not_see_within_seconds("The text is here!", "10").should be_true
        @st.do_not_see("The text is here!").should be_true
      end
      it "text disappears within default time" do
        @st.see_within_seconds("The text is here!", 10).should be_true
        @st.do_not_see_within_seconds("The text is here!").should be_true
        @st.do_not_see("The text is here!").should be_true
      end
    end

    context "fails when" do
      it "text disappears too late" do
        @st.see_within_seconds("The text is here!", 10).should be_true
        @st.do_not_see_within_seconds("The text is here!", 1).should be_false
      end
      it "text never disappears" do
        @st.do_not_see_within_seconds("The text is coming...", 5).should be_false
      end
    end
  end

end