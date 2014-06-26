require_relative 'st_spec_helper'

describe '#method_missing' do
  context "method is defined in Selenium::Client::Driver" do
    before(:each) do
      expect(@st.visit("/form")).to be true
    end

    context "method returning Boolean" do
      it "passes if method returns true" do
        expect(@st.is_element_present("id=first_name")).to be true
        expect(@st.is_visible("id=first_name")).to be true
        expect(@st.is_text_present("This page has some random forms")).to be true
      end

      it "fails if method returns false" do
        expect(@st.is_element_present("id=bogus_id")).to be false
        expect(@st.is_visible("id=bogus_id")).to be false
        expect(@st.is_text_present("This text is not there")).to be false
      end
    end

    context "method returning String" do
      it "returns the string" do
        expect(@st.get_text("id=salami_checkbox")).to eq("I like salami")
      end
    end

    context "method verifying String" do
      it "verifies the right string" do
        expect(@st.check_get_text("id=salami_checkbox", "I like salami")).to be true
      end
      it "does not verify the wrong string" do
        expect(@st.check_get_text("id=salami_checkbox", "I like lima beans")).to be false
      end
    end

    context "method not returning Boolean or String" do
      it "passes if method doesn't raise an exception" do
        expect(@st.get_title).to be true
        expect(@st.mouse_over("id=first_name")).to be true
      end

      it "fails if method raises an exception" do
        expect(@st.double_click("id=bogus_id")).to be false
        expect(@st.mouse_over("id=bogus_id")).to be false
      end
    end
  end # Selenium::Client::Driver

  context "method is not defined in Selenium::Client::Driver" do
    it "raises an exception" do
      expect {
        @st.really_undefined_method
      }.to raise_error
    end
  end
end

