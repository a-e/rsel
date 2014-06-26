require_relative 'st_spec_helper'

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

      it "sees text within an id" do
        @st.see("About this site", :within => 'header').should be_true
      end
    end

    context "fails when" do
      it "text is absent" do
        @st.errors
        @st.see("Nonexistent").should be_false
        @st.see("Some bogus text").should be_false
        @st.errors.should eq('')
      end
      it "text is present, but invisible" do
        @st.errors
        @st.see("unseen").should be_false
        @st.errors.should eq('')
      end
      it "text is present, but invisible, using studying" do
        @st.errors
        @st.begin_study
        @st.see("unseen").should be_false
        @st.end_study
        @st.errors.should eq('')
      end
      it "text is present, but not within the scope" do
        @st.errors
        @st.see("This is a Sinatra webapp", :within => 'header').should be_false
        @st.errors.should eq("'This is a Sinatra webapp' not found in 'About this site'")
      end
      it "text is present, within scope, but invisible" do
        @st.errors
        @st.see("unseen", :within => 'header').should be_false
        @st.errors.should eq("'unseen' not found in 'About this site'")
      end
      it "text is present, studied within scope, but invisible" do
        @st.errors
        @st.begin_study
        @st.see("unseen", :within => 'header').should be_false
        @st.end_study
        @st.errors.should eq("'unseen' not found in 'About this site'")
      end
      it "scope is not present" do
        @st.see("This is a Sinatra webapp", :within => 'bogus_id').should be_false
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
      it "text is present, but invisible" do
        @st.errors
        @st.do_not_see("unseen").should be_true
        @st.errors.should eq('')
      end
      it "text is present, but invisible, using studying" do
        @st.errors
        @st.begin_study
        @st.do_not_see("unseen").should be_true
        @st.end_study
        @st.errors.should eq('')
      end
      it "text is present, but not within the scope" do
        @st.do_not_see("This is a Sinatra webapp", :within => 'header').should be_true
      end
      it "text is present, within scope, but invisible" do
        @st.errors
        @st.do_not_see("unseen", :within => 'header').should be_true
        @st.errors.should eq('')
      end
      it "text is present, studied within scope, but invisible" do
        @st.errors
        @st.begin_study
        @st.do_not_see("unseen", :within => 'header').should be_true
        @st.end_study
        @st.errors.should eq('')
      end
      it "scope is not present" do
        @st.do_not_see("This is a Sinatra webapp", :within => 'bogus_id').should be_true
      end
    end

    context "fails when" do
      it "text is present" do
        @st.errors
        @st.do_not_see("Welcome").should be_false
        @st.do_not_see("This is a Sinatra webapp").should be_false
        @st.errors.should eq('')
      end
      it "sees text within an id" do
        @st.errors
        @st.do_not_see("About this site", :within => 'header').should be_false
        @st.errors.should eq("'About this site' not expected, but found in 'About this site'")
      end
    end

    it "is case-sensitive" do
      @st.do_not_see("Sinatra webapp").should be_false
      @st.do_not_see("sinatra Webapp").should be_true
    end
  end

end
