require_relative 'wt_spec_helper'

describe 'navigation' do
  before(:each) do
    @wt.visit("/").should be_true
  end

  describe "#visit" do
    context "passes when" do
      it "page exists" do
        @wt.visit("/about").should be_true
      end
    end

    # FIXME: Selenium server 2.3.0 and 2.4.0 no longer fail
    # when a 404 or 500 error is raised
    #context "fails when" do
      #it "page gets a 404 error" do
        #@wt.visit("/404").should be_false
      #end
      #it "page gets a 500 error" do
        #@wt.visit("/500").should be_false
      #end
    #end
  end

  describe "#refresh_page" do
    before(:each) do
      @wt.visit("/slowtext").should be_true
    end

    it "reloads the page" do
      @wt.see("The text is coming...").should be_true
      @wt.do_not_see("The text is here!").should be_true
      @wt.see_within_seconds("The text is here!").should be_true
      @wt.refresh_page
      @wt.page_loads_in_seconds_or_less(10)
      @wt.do_not_see("The text is here!").should be_true
    end
  end

  describe "#click_back" do
    it "passes and loads the correct URL" do
      @wt.visit("/about")
      @wt.visit("/")
      @wt.click_back.should be_true
      @wt.see_title("About this site").should be_true
    end

    #it "fails when there is no previous page in the history" do
      # TODO: No obvious way to test this, since everything is running in the
      # same session
    #end
  end

end
