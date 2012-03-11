require 'spec/st_spec_helper'

describe 'links' do
  before(:each) do
    @st.visit("/").should be_true
  end

  describe "#click" do
    context "passes when" do
      it "link exists" do
        @st.click("About this site").should be_true
      end
    end

    context "fails when" do
      it "link does not exist" do
        @st.click("Bogus link").should be_false
      end
    end
  end

  describe "#click_link" do
    context "passes when" do
      it "link exists" do
        @st.click_link("About this site").should be_true
      end

      it "link exists within scope" do
        @st.click_link("About this site", :within => "header").should be_true
      end

      it "link exists in table row" do
        @st.visit("/table")
        @st.click_link("Edit", :in_row => "Marcus").should be_true
        @st.page_loads_in_seconds_or_less(10).should be_true
        @st.see_title("Editing Marcus").should be_true
      end
    end

    context "fails when" do
      it "link does not exist" do
        @st.click_link("Bogus link").should be_false
      end

      it "link exists, but not within scope" do
        @st.click_link("About this site", :within => "footer").should be_false
      end

      it "link exists, but not in table row" do
        @st.visit("/table")
        @st.click_link("Edit", :in_row => "Ken").should be_false
      end
    end
  end

  describe "#link_exists" do
    context "passes when" do
      it "link with the given text exists" do
        @st.link_exists("About this site").should be_true
        @st.link_exists("Form test").should be_true
      end

      it "link with the given text exists within scope" do
        @st.link_exists("About this site", :within => "header").should be_true
        @st.link_exists("Form test", :within => "footer").should be_true
        @st.link_exists("Table test", :within => "footer").should be_true
      end
    end

    context "fails when" do
      it "no such link exists" do
        @st.link_exists("Welcome").should be_false
        @st.link_exists("Don't click here").should be_false
      end

      it "link exists, but not within scope" do
        @st.link_exists("About this site", :within => "footer").should be_false
        @st.link_exists("Form test", :within => "header").should be_false
        @st.link_exists("Table test", :within => "header").should be_false
      end
    end
  end

end
