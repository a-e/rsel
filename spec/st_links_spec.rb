require_relative 'st_spec_helper'

describe 'links' do
  before(:each) do
    @st.visit("/").should be true
  end

  describe "#click" do
    context "passes when" do
      it "link exists" do
        @st.click("About this site").should be true
      end
    end

    context "fails when" do
      it "link does not exist" do
        @st.click("Bogus link").should be false
      end
    end
  end

  describe "#click_link" do
    context "passes when" do
      it "link exists" do
        @st.click_link("About this site").should be true
      end

      it "link exists within scope" do
        @st.click_link("About this site", :within => "header").should be true
      end

      it "link exists in table row" do
        @st.visit("/table")
        @st.click_link("Edit", :in_row => "Marcus").should be true
        @st.page_loads_in_seconds_or_less(10).should be true
        @st.see_title("Editing Marcus").should be true
      end
    end

    context "fails when" do
      it "link does not exist" do
        @st.click_link("Bogus link").should be false
      end

      it "link exists, but not within scope" do
        @st.click_link("About this site", :within => "footer").should be false
      end

      it "link exists, but not in table row" do
        @st.visit("/table")
        @st.click_link("Edit", :in_row => "Ken").should be false
      end
    end
  end

  describe "#link_exists" do
    context "passes when" do
      it "link with the given text exists" do
        @st.link_exists("About this site").should be true
        @st.link_exists("Form test").should be true
      end

      it "link with the given text exists within scope" do
        @st.link_exists("About this site", :within => "header").should be true
        @st.link_exists("Form test", :within => "footer").should be true
        @st.link_exists("Table test", :within => "footer").should be true
      end
    end

    context "fails when" do
      it "no such link exists" do
        @st.link_exists("Welcome").should be false
        @st.link_exists("Don't click here").should be false
      end

      it "link exists, but not within scope" do
        @st.link_exists("About this site", :within => "footer").should be false
        @st.link_exists("Form test", :within => "header").should be false
        @st.link_exists("Table test", :within => "header").should be false
      end
    end
  end

end
