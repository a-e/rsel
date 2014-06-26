require_relative 'wt_spec_helper'

describe '#method_missing' do
  context "method is defined in Selenium::Client::Driver" do
    before(:each) do
      @wt.visit("/form").should be_true
    end

    context "method returning Boolean" do
      it "passes if method returns true" do
        @wt.is_element_present("id=first_name").should be_true
        @wt.is_visible("id=first_name").should be_true
        @wt.is_text_present("This page has some random forms").should be_true
      end

      it "fails if method returns false" do
        @wt.is_element_present("id=bogus_id").should be_false
        @wt.is_visible("id=bogus_id").should be_false
        @wt.is_text_present("This text is not there").should be_false
      end
    end

    context "method returning String" do
      it "returns the string" do
        @wt.get_text("id=salami_checkbox").should eq("I like salami")
      end
    end

    context "method verifying String" do
      it "verifies the right string" do
        @wt.check_get_text("id=salami_checkbox", "I like salami").should be_true
      end
      it "does not verify the wrong string" do
        @wt.check_get_text("id=salami_checkbox", "I like lima beans").should be_false
      end
    end

    context "method not returning Boolean or String" do
      it "passes if method doesn't raise an exception" do
        @wt.get_title.should be_true
        @wt.mouse_over("id=first_name").should be_true
      end

      it "fails if method raises an exception" do
        @wt.double_click("id=bogus_id").should be_false
        @wt.mouse_over("id=bogus_id").should be_false
      end
    end
  end # Selenium::Client::Driver

  context "method is not defined in Selenium::Client::Driver" do
    it "raises an exception" do
      lambda do
        @wt.really_undefined_method
      end.should raise_error
    end
  end
end

