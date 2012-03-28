require 'spec/wt_spec_helper'

describe 'visibility' do
  before(:each) do
    @wt.visit("/").should be_true
  end

  describe "#see" do
    context "passes when" do
      it "text is present" do
        @wt.see("Welcome").should be_true
        @wt.see("This is a Sinatra webapp").should be_true
      end

      it "sees text within an id" do
        @wt.see("About this site", :within => 'header').should be_true
      end
    end

    context "fails when" do
      it "text is absent" do
        @wt.errors
        @wt.see("Nonexistent").should be_false
        @wt.see("Some bogus text").should be_false
        @wt.errors.should eq('')
      end
      it "text is present, but invisible" do
        @wt.errors
        @wt.see("unseen").should be_false
        @wt.errors.should eq('')
      end
      it "text is present, but invisible, using studying" do
        @wt.errors
        @wt.begin_study
        @wt.see("unseen").should be_false
        @wt.end_study
        @wt.errors.should eq('')
      end
      it "text is present, but not within the scope" do
        @wt.errors
        @wt.see("This is a Sinatra webapp", :within => 'header').should be_false
        @wt.errors.should eq("'This is a Sinatra webapp' not found in 'About this site'")
      end
      it "text is present, within scope, but invisible" do
        @wt.errors
        @wt.see("unseen", :within => 'header').should be_false
        @wt.errors.should eq("'unseen' not found in 'About this site'")
      end
      it "text is present, studied within scope, but invisible" do
        @wt.errors
        @wt.begin_study
        @wt.see("unseen", :within => 'header').should be_false
        @wt.end_study
        @wt.errors.should eq("'unseen' not found in 'About this site'")
      end
      it "scope is not present" do
        @wt.see("This is a Sinatra webapp", :within => 'bogus_id').should be_false
      end
    end

    it "is case-sensitive" do
      @wt.see("Sinatra webapp").should be_true
      @wt.see("sinatra Webapp").should be_false
    end
  end

  describe "#do_not_see" do
    context "passes when" do
      it "text is absent" do
        @wt.do_not_see("Nonexistent").should be_true
        @wt.do_not_see("Some bogus text").should be_true
      end
      it "text is present, but invisible" do
        @wt.errors
        @wt.do_not_see("unseen").should be_true
        @wt.errors.should eq('')
      end
      it "text is present, but invisible, using studying" do
        @wt.errors
        @wt.begin_study
        @wt.do_not_see("unseen").should be_true
        @wt.end_study
        @wt.errors.should eq('')
      end
      it "text is present, but not within the scope" do
        @wt.do_not_see("This is a Sinatra webapp", :within => 'header').should be_true
      end
      it "text is present, within scope, but invisible" do
        @wt.errors
        @wt.do_not_see("unseen", :within => 'header').should be_true
        @wt.errors.should eq('')
      end
      it "text is present, studied within scope, but invisible" do
        @wt.errors
        @wt.begin_study
        @wt.do_not_see("unseen", :within => 'header').should be_true
        @wt.end_study
        @wt.errors.should eq('')
      end
      it "scope is not present" do
        @wt.do_not_see("This is a Sinatra webapp", :within => 'bogus_id').should be_true
      end
    end

    context "fails when" do
      it "text is present" do
        @wt.errors
        @wt.do_not_see("Welcome").should be_false
        @wt.do_not_see("This is a Sinatra webapp").should be_false
        @wt.errors.should eq('')
      end
      it "sees text within an id" do
        @wt.errors
        @wt.do_not_see("About this site", :within => 'header').should be_false
        @wt.errors.should eq("'About this site' found in 'About this site'")
      end
    end

    it "is case-sensitive" do
      @wt.do_not_see("Sinatra webapp").should be_false
      @wt.do_not_see("sinatra Webapp").should be_true
    end
  end

end
