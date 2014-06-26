require_relative 'st_spec_helper'

describe 'links' do
  before(:each) do
    expect(@st.visit("/")).to be true
  end

  describe "#click" do
    context "passes when" do
      it "link exists" do
        expect(@st.click("About this site")).to be true
      end
    end

    context "fails when" do
      it "link does not exist" do
        expect(@st.click("Bogus link")).to be false
      end
    end
  end

  describe "#click_link" do
    context "passes when" do
      it "link exists" do
        expect(@st.click_link("About this site")).to be true
      end

      it "link exists within scope" do
        expect(@st.click_link("About this site", :within => "header")).to be true
      end

      it "link exists in table row" do
        @st.visit("/table")
        expect(@st.click_link("Edit", :in_row => "Marcus")).to be true
        expect(@st.page_loads_in_seconds_or_less(10)).to be true
        expect(@st.see_title("Editing Marcus")).to be true
      end
    end

    context "fails when" do
      it "link does not exist" do
        expect(@st.click_link("Bogus link")).to be false
      end

      it "link exists, but not within scope" do
        expect(@st.click_link("About this site", :within => "footer")).to be false
      end

      it "link exists, but not in table row" do
        @st.visit("/table")
        expect(@st.click_link("Edit", :in_row => "Ken")).to be false
      end
    end
  end

  describe "#link_exists" do
    context "passes when" do
      it "link with the given text exists" do
        expect(@st.link_exists("About this site")).to be true
        expect(@st.link_exists("Form test")).to be true
      end

      it "link with the given text exists within scope" do
        expect(@st.link_exists("About this site", :within => "header")).to be true
        expect(@st.link_exists("Form test", :within => "footer")).to be true
        expect(@st.link_exists("Table test", :within => "footer")).to be true
      end
    end

    context "fails when" do
      it "no such link exists" do
        expect(@st.link_exists("Welcome")).to be false
        expect(@st.link_exists("Don't click here")).to be false
      end

      it "link exists, but not within scope" do
        expect(@st.link_exists("About this site", :within => "footer")).to be false
        expect(@st.link_exists("Form test", :within => "header")).to be false
        expect(@st.link_exists("Table test", :within => "header")).to be false
      end
    end
  end

end
