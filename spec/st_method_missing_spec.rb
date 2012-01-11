require 'spec/spec_helper'

describe '#method_missing' do
  context "method is defined in Selenium::Client::Driver" do
    before(:each) do
      @st.visit("/form").should be_true
    end

    context "method returning Boolean" do
      it "passes if method returns true" do
        @st.is_element_present("id=first_name").should be_true
        @st.is_visible("id=first_name").should be_true
        @st.is_text_present("This page has some random forms").should be_true
      end

      it "fails if method returns false" do
        @st.is_element_present("id=bogus_id").should be_false
        @st.is_visible("id=bogus_id").should be_false
        @st.is_text_present("This text is not there").should be_false
      end
    end

    context "method returning String" do
      it "returns the String" do
        @st.get_text("id=salami_checkbox").should eq("I like salami")
      end
    end

    context "method not returning Boolean or String" do
      it "passes if method doesn't raise an exception" do
        @st.get_title.should be_true
        @st.mouse_over("id=first_name").should be_true
      end

      it "fails if method raises an exception" do
        @st.double_click("id=bogus_id").should be_false
        @st.mouse_over("id=bogus_id").should be_false
      end
    end
  end # Selenium::Client::Driver

  context "method is not defined in Selenium::Client::Driver" do
    it "raises an exception" do
      lambda do
        @st.really_undefined_method
      end.should raise_error
    end
  end
end

