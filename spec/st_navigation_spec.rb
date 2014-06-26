require_relative 'st_spec_helper'

describe 'navigation' do
  before(:each) do
    expect(@st.visit("/")).to be true
  end

  describe "#visit" do
    context "passes when" do
      it "page exists" do
        expect(@st.visit("/about")).to be true
      end
    end

    # FIXME: Selenium server 2.3.0 and 2.4.0 no longer fail
    # when a 404 or 500 error is raised
    #context "fails when" do
      #it "page gets a 404 error" do
        #expect(@st.visit("/404")).to be false
      #end
      #it "page gets a 500 error" do
        #expect(@st.visit("/500")).to be false
      #end
    #end
  end

  describe "#refresh_page" do
    before(:each) do
      expect(@st.visit("/slowtext")).to be true
    end

    it "reloads the page" do
      expect(@st.see("The text is coming...")).to be true
      expect(@st.do_not_see("The text is here!")).to be true
      expect(@st.see_within_seconds("The text is here!")).to be true
      @st.refresh_page
      @st.page_loads_in_seconds_or_less(10)
      expect(@st.do_not_see("The text is here!")).to be true
    end
  end

  describe "#click_back" do
    it "passes and loads the correct URL" do
      @st.visit("/about")
      @st.visit("/")
      @st.click_back.should be true
      expect(@st.see_title("About this site")).to be true
    end

    #it "fails when there is no previous page in the history" do
      # TODO: No obvious way to test this, since everything is running in the
      # same session
    #end
  end

end
