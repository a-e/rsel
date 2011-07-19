require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest do
  context 'initialization' do
    before(:each) do
      @st.visit('/')
    end

    it "sets correct default configuration" do
      @st.url.should == 'http://localhost:8070/'
      @st.browser.host.should == 'localhost'
      @st.browser.port.should == 4444
    end
  end


  context 'checkbox' do
    before(:each) do
      @st.visit('/form').should be_true
    end

    context "enable" do
      context "passes when" do
        it "checkbox with the given label is present" do
          @st.enable_checkbox("I like cheese").should be_true
          @st.enable_checkbox("I like salami").should be_true
        end
      end

      context "fails when" do
        it "checkbox with the given label is absent" do
          @st.enable_checkbox("I dislike bacon").should be_false
          @st.enable_checkbox("I like broccoli").should be_false
        end
      end
    end
  end


  context 'dropdown' do
    before(:each) do
      @st.visit('/form').should be_true
    end

    context "select" do
      context "passes when" do
        it "value exists in a dropdown" do
          @st.select_from_dropdown("Tall", "Height").should be_true
          @st.select_from_dropdown("Medium", "Weight").should be_true
        end
      end

      context "fails when" do
        it "dropdown exists, but the value doesn't" do
          @st.select_from_dropdown("Giant", "Height").should be_false
          @st.select_from_dropdown("Obese", "Weight").should be_false
        end

        it "no such dropdown exists" do
          @st.select_from_dropdown("Over easy", "Eggs").should be_false
        end
      end
    end

    context "verify" do
      # TODO
    end
  end


  context 'navigation' do
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


  context 'text field' do
    before(:each) do
      @st.visit('/form').should be_true
    end

    context "type into or fill in" do
      context "passes when" do
        it "text field with the given label exists" do
          @st.type_into_field("Eric", "First name").should be_true
          @st.fill_in_with("Last name", "Pierce").should be_true
        end

        it "text field with the given id exists" do
          @st.type_into_field("Eric", "first_name").should be_true
          @st.fill_in_with("last_name", "Pierce").should be_true
        end

        it "texarea with the given label exists" do
          @st.type_into_field("Blah blah blah", "Life story").should be_true
          @st.fill_in_with("Life story", "Jibber jabber").should be_true
        end

        it "texarea with the given id exists" do
          @st.type_into_field("Blah blah blah", "biography").should be_true
          @st.fill_in_with("biography", "Jibber jabber").should be_true
        end
      end

      context "fails when" do
        it "no field with the given label or id exists" do
          @st.type_into_field("Matthew", "Middle name").should be_false
          @st.fill_in_with("middle_name", "Matthew").should be_false
        end
      end
    end

    context "should contain" do
      context "passes when" do
        it "textarea contains the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_contains("Life story", "blah").should be_true
        end
      end

      context "fails when" do
        it "textarea does not contain the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_contains("Life story", "spam").should be_false
        end
      end
    end

    context "should equal" do
      context "passes when" do
        it "textarea equals the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_equals("Life story", "Blah dee blah").should be_true
        end
      end

      context "fails when" do
        it "textarea does not exactly equal the text" do
          @st.fill_in_with("Life story", "Blah dee blah")
          @st.field_equals("Life story", "Blah dee").should be_false
        end
      end
    end
  end


  context 'visibility' do
    before(:each) do
      @st.visit('/').should be_true
    end

    context "should see" do
      context "passes when" do
        it "text is present" do
          @st.see('Welcome').should be_true
          @st.see('This is a Sinatra webapp').should be_true
        end
      end

      context "fails when" do
        it "text is absent" do
          @st.see('Nonexistent').should be_false
          @st.see('Some bogus text').should be_false
        end
      end

      it "is case-sensitive" do
        @st.see('Sinatra webapp').should be_true
        @st.see('sinatra Webapp').should be_false
      end
    end

    context "should not see" do
      context "passes when" do
        it "text is absent" do
          @st.do_not_see('Nonexistent').should be_true
          @st.do_not_see('Some bogus text').should be_true
        end
      end

      context "fails when" do
        it "fails when test is present" do
          @st.do_not_see('Welcome').should be_false
          @st.do_not_see('This is a Sinatra webapp').should be_false
        end
      end

      it "is case-sensitive" do
        @st.do_not_see('Sinatra webapp').should be_false
        @st.do_not_see('sinatra Webapp').should be_true
      end
    end
  end

end

