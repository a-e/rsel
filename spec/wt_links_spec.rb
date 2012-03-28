require 'spec/wt_spec_helper'

describe 'links' do
  before(:each) do
    @wt.visit("/").should be_true
  end

  describe "#click" do
    context "passes when" do
      it "link exists" do
        @wt.click("About this site").should be_true
      end
    end

    context "fails when" do
      it "link does not exist" do
        @wt.click("Bogus link").should be_false
      end
    end
  end

  describe "#click_link" do
    context "passes when" do
      it "link exists" do
        @wt.click_link("About this site").should be_true
      end

      it "link exists within scope" do
        @wt.click_link("About this site", :within => "header").should be_true
      end

      it "link exists in table row" do
        @wt.visit("/table")
        @wt.click_link("Edit", :in_row => "Marcus").should be_true
        @wt.page_loads_in_seconds_or_less(10).should be_true
        @wt.see_title("Editing Marcus").should be_true
      end
    end

    context "fails when" do
      it "link does not exist" do
        @wt.click_link("Bogus link").should be_false
      end

      it "link exists, but not within scope" do
        @wt.click_link("About this site", :within => "footer").should be_false
      end

      it "link exists, but not in table row" do
        @wt.visit("/table")
        @wt.click_link("Edit", :in_row => "Ken").should be_false
      end
    end
  end

  describe "#link_exists" do
    context "passes when" do
      it "link with the given text exists" do
        @wt.link_exists("About this site").should be_true
        @wt.link_exists("Form test").should be_true
      end

      it "link with the given text exists within scope" do
        @wt.link_exists("About this site", :within => "header").should be_true
        @wt.link_exists("Form test", :within => "footer").should be_true
        @wt.link_exists("Table test", :within => "footer").should be_true
      end
    end

    context "fails when" do
      it "no such link exists" do
        @wt.link_exists("Welcome").should be_false
        @wt.link_exists("Don't click here").should be_false
      end

      it "link exists, but not within scope" do
        @wt.link_exists("About this site", :within => "footer").should be_false
        @wt.link_exists("Form test", :within => "header").should be_false
        @wt.link_exists("Table test", :within => "header").should be_false
      end
    end
  end

end
