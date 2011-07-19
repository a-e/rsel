require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest, 'navigation' do
  before(:each) do
    @st.visit('/').should be_true
  end

  context "visit" do
    context "passes when" do
      it "page exists" do
        @st.visit("/about").should be_true
      end
    end

    context "fails when" do
      it "page does not exist" do
        @st.visit("/bad/path").should be_false
      end
    end
  end

  context "reload the current page" do
    # TODO
  end

  context "go back to the previous page" do
    it "passes and loads the correct URL" do
      @st.visit("/about")
      @st.visit("/")
      @st.click_back.should be_true
      @st.see_title("About this site").should be_true
    end

    #it "fails when there is no previous page in the history" do
      # TODO: No obvious way to test this, since everything is running in the
      # same session
    #end
  end

  context "clicking a link" do
    it "passes and loads the correct page when a link exists" do
      @st.click_link("About this site").should be_true
      @st.see_title("About this site").should be_true
      @st.see("This site is really cool").should be_true
    end

    it "fails when a link does not exist" do
      @st.follow("Bogus link").should be_false
    end
  end

end
