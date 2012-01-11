require 'spec/spec_helper'

describe 'visibility' do
  before(:each) do
    @st.visit("/").should be_true
  end

  describe "#see" do
    context "passes when" do
      it "text is present" do
        @st.see("Welcome").should be_true
        @st.see("This is a Sinatra webapp").should be_true
      end
    end

    context "fails when" do
      it "text is absent" do
        @st.errors
        @st.see("Nonexistent").should be_false
        @st.see("Some bogus text").should be_false
        @st.errors.should eq('')
      end
    end

    it "is case-sensitive" do
      @st.see("Sinatra webapp").should be_true
      @st.see("sinatra Webapp").should be_false
    end
  end

  describe "#do_not_see" do
    context "passes when" do
      it "text is absent" do
        @st.do_not_see("Nonexistent").should be_true
        @st.do_not_see("Some bogus text").should be_true
      end
    end

    context "fails when" do
      it "text is present" do
        @st.errors
        @st.do_not_see("Welcome").should be_false
        @st.do_not_see("This is a Sinatra webapp").should be_false
        @st.errors.should eq('')
      end
    end

    it "is case-sensitive" do
      @st.do_not_see("Sinatra webapp").should be_false
      @st.do_not_see("sinatra Webapp").should be_true
    end
  end

end
