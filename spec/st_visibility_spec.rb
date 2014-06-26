require_relative 'st_spec_helper'

describe 'visibility' do
  before(:each) do
    expect(@st.visit("/")).to be true
  end

  describe "#see" do
    context "passes when" do
      it "text is present" do
        expect(@st.see("Welcome")).to be true
        expect(@st.see("This is a Sinatra webapp")).to be true
      end

      it "sees text within an id" do
        expect(@st.see("About this site", :within => 'header')).to be true
      end
    end

    context "fails when" do
      it "text is absent" do
        @st.errors
        expect(@st.see("Nonexistent")).to be false
        expect(@st.see("Some bogus text")).to be false
        expect(@st.errors).to eq('')
      end
      it "text is present, but invisible" do
        @st.errors
        expect(@st.see("unseen")).to be false
        expect(@st.errors).to eq('')
      end
      it "text is present, but invisible, using studying" do
        @st.errors
        @st.begin_study
        expect(@st.see("unseen")).to be false
        @st.end_study
        expect(@st.errors).to eq('')
      end
      it "text is present, but not within the scope" do
        @st.errors
        expect(@st.see("This is a Sinatra webapp", :within => 'header')).to be false
        expect(@st.errors).to eq("'This is a Sinatra webapp' not found in 'About this site'")
      end
      it "text is present, within scope, but invisible" do
        @st.errors
        expect(@st.see("unseen", :within => 'header')).to be false
        expect(@st.errors).to eq("'unseen' not found in 'About this site'")
      end
      it "text is present, studied within scope, but invisible" do
        @st.errors
        @st.begin_study
        expect(@st.see("unseen", :within => 'header')).to be false
        @st.end_study
        expect(@st.errors).to eq("'unseen' not found in 'About this site'")
      end
      it "scope is not present" do
        expect(@st.see("This is a Sinatra webapp", :within => 'bogus_id')).to be false
      end
    end

    it "is case-sensitive" do
      expect(@st.see("Sinatra webapp")).to be true
      expect(@st.see("sinatra Webapp")).to be false
    end
  end

  describe "#do_not_see" do
    context "passes when" do
      it "text is absent" do
        expect(@st.do_not_see("Nonexistent")).to be true
        expect(@st.do_not_see("Some bogus text")).to be true
      end
      it "text is present, but invisible" do
        @st.errors
        expect(@st.do_not_see("unseen")).to be true
        expect(@st.errors).to eq('')
      end
      it "text is present, but invisible, using studying" do
        @st.errors
        @st.begin_study
        expect(@st.do_not_see("unseen")).to be true
        @st.end_study
        expect(@st.errors).to eq('')
      end
      it "text is present, but not within the scope" do
        expect(@st.do_not_see("This is a Sinatra webapp", :within => 'header')).to be true
      end
      it "text is present, within scope, but invisible" do
        @st.errors
        expect(@st.do_not_see("unseen", :within => 'header')).to be true
        expect(@st.errors).to eq('')
      end
      it "text is present, studied within scope, but invisible" do
        @st.errors
        @st.begin_study
        expect(@st.do_not_see("unseen", :within => 'header')).to be true
        @st.end_study
        expect(@st.errors).to eq('')
      end
      it "scope is not present" do
        expect(@st.do_not_see("This is a Sinatra webapp", :within => 'bogus_id')).to be true
      end
    end

    context "fails when" do
      it "text is present" do
        @st.errors
        expect(@st.do_not_see("Welcome")).to be false
        expect(@st.do_not_see("This is a Sinatra webapp")).to be false
        expect(@st.errors).to eq('')
      end
      it "sees text within an id" do
        @st.errors
        expect(@st.do_not_see("About this site", :within => 'header')).to be false
        expect(@st.errors).to eq("'About this site' not expected, but found in 'About this site'")
      end
    end

    it "is case-sensitive" do
      expect(@st.do_not_see("Sinatra webapp")).to be false
      expect(@st.do_not_see("sinatra Webapp")).to be true
    end
  end

end
