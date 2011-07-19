require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest do
  before(:all) do
    @st = Rsel::SeleniumTest.new('http://localhost:8070/')
    @st.open_browser
  end

  before(:each) do
    @st.visit('/')
  end

  after(:all) do
    @st.close_browser
  end


  context "initialization" do
    it "sets correct default configuration" do
      @st.url.should == 'http://localhost:8070/'
      @st.browser.host.should == 'localhost'
      @st.browser.port.should == 4444
    end
  end


  context "visibility" do
    context "should see" do
      it "passes when text is present" do
        @st.should_see('Welcome').should == true
        @st.should_see('This is a Sinatra webapp').should == true
      end

      it "fails when text is absent" do
        @st.should_see('Nonexistent').should == false
        @st.should_see('Some bogus text').should == false
      end

      it "is case-sensitive" do
        @st.should_see('Sinatra webapp').should == true
        @st.should_see('sinatra Webapp').should == false
      end
    end

    context "should not see" do
      it "passes when text is absent" do
        @st.should_not_see('Nonexistent').should == true
        @st.should_not_see('Some bogus text').should == true
      end

      it "fails when test is present" do
        @st.should_not_see('Welcome').should == false
        @st.should_not_see('This is a Sinatra webapp').should == false
      end

      it "is case-sensitive" do
        @st.should_not_see('Sinatra webapp').should == false
        @st.should_not_see('sinatra Webapp').should == true
      end
    end
  end

  context "text fields" do
    context "type into or fill in field" do
      it "passes when a text field with the given label exists" do
        @st.type_into_field("Eric", "First name").should == true
        @st.fill_in_with("Last name", "Pierce").should == true
      end

      it "passes when a text field with the given id exists" do
        @st.type_into_field("Eric", "first_name").should == true
        @st.fill_in_with("last_name", "Pierce").should == true
      end

      it "passes when a texarea with the given label exists" do
        @st.type_into_field("Blah blah blah", "Life story").should == true
        @st.fill_in_with("Life story", "Jibber jabber").should == true
      end

      it "passes when a texarea with the given id exists" do
        @st.type_into_field("Blah blah blah", "biography").should == true
        @st.fill_in_with("biography", "Jibber jabber").should == true
      end

      it "fails when no field with the given label or id exists" do
        @st.type_into_field("Matthew", "Middle name").should == false
        @st.fill_in_with("middle_name", "Matthew").should == false
      end
    end

    context "verify the contents of a text field" do
      # TODO
    end

  end

  context "dropdowns" do
    context "select from a dropdown" do
      it "passes when a value exists in a dropdown" do
        @st.select_from_dropdown("Tall", "Height").should == true
        @st.select_from_dropdown("Medium", "Weight").should == true
      end

      it "fails when a dropdown exists, but the value doesn't" do
        @st.select_from_dropdown("Giant", "Height").should == false
        @st.select_from_dropdown("Obese", "Weight").should == false
      end

      it "fails when no such dropdown exists" do
        @st.select_from_dropdown("Over easy", "Eggs").should == false
      end
    end

    context "verify the contents of a dropdown" do
      # TODO
    end
  end

  context "navigation" do
    context "visit a page" do
      it "passes when the page exists" do
        @st.visit("/about").should == true
      end

      it "fails when the page does not exist" do
        @st.visit("/bad/path").should == false
      end
    end

    context "reload the current page" do
      # TODO
    end

    context "go back to the previous page" do
      it "passes and loads the correct URL" do
        @st.visit("/about")
        @st.visit("/")
        @st.click_back.should == true
        @st.should_see_title("About this site").should == true
      end

      #it "fails when there is no previous page in the history" do
        # TODO: No obvious way to test this, since everything is running in the
        # same session
      #end
    end

    context "clicking a link" do
      it "passes and loads the correct page when a link exists" do
        @st.click_link("About this site").should == true
        @st.should_see_title("About this site").should == true
        @st.should_see("This site is really cool").should == true
      end

      it "fails when a link does not exist" do
        @st.click_link("Bogus link").should == false
      end
    end
  end

end

