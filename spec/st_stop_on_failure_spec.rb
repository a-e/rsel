require_relative 'st_spec_helper'

describe 'stop on failure' do
  before(:each) do
    expect(@st.visit("/")).to be true
    @st.stop_on_failure = true
    @st.found_failure = false
  end

  after(:each) do
    @st.stop_on_failure = false
  end

  context "causes subsequent steps to fail" do
    it "when #see fails" do
      expect(@st.see("Nonexistent")).to be false
      # Would pass, but previous step failed
      expect(@st.see("Welcome")).to be false
    end

    it "when #do_not_see fails" do
      expect(@st.do_not_see("Welcome")).to be false
      # Would pass, but previous step failed
      expect(@st.do_not_see("Nonexistent")).to be false
    end

    it "when #see_title fails" do
      @st.errors # clear errors
      expect(@st.see_title("Wrong Title")).to be false
      # Would pass, but previous step failed
      expect(@st.see_title("Rsel Test Site")).to be false
      # Should see one and only one error.
      expect(@st.errors).to eq("Page title is 'Rsel Test Site', not 'Wrong Title'")
    end

    it "when #do_not_see_title fails" do
      expect(@st.do_not_see_title("Rsel Test Site")).to be false
      # Would pass, but previous step failed
      expect(@st.do_not_see_title("Wrong title")).to be false
    end

    it "when #link_exists fails" do
      expect(@st.link_exists("Bogus Link")).to be false
      # Would pass, but previous step failed
      expect(@st.link_exists("About this site")).to be false
    end

    it "when #button_exists fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.button_exists("Bogus Button")).to be false
      # Would pass, but previous step failed
      expect(@st.button_exists("Submit person form")).to be false
    end

    it "when #row_exists fails" do
      expect(@st.visit("/table")).to be true
      expect(@st.row_exists("No, Such, Row")).to be false
      # Would pass, but previous step failed
      expect(@st.row_exists("First name, Last name, Email")).to be false
    end

    it "when #type_into_field fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.type_into_field("Hello", "Bad Field")).to be false
      # Would pass, but previous step failed
      expect(@st.type_into_field("Eric", "First name")).to be false
    end

    it "when #field_contains fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.field_contains("Bad Field", "Hello")).to be false
      # Would pass, but previous step failed
      expect(@st.field_contains("First name", "Marcus")).to be false
    end

    it "when #field_equals fails" do
      expect(@st.visit("/form")).to be true
      @st.fill_in_with("First name", "Ken")
      expect(@st.field_equals("First name", "Eric")).to be false
      # Would pass, but previous step failed
      expect(@st.field_equals("First name", "Ken")).to be false
    end

    it "when #click fails" do
      expect(@st.click("No Such Link")).to be false
      # Would pass, but previous step failed
      expect(@st.click("About this site")).to be false
    end

    it "when #click_link fails" do
      expect(@st.click_link("No Such Link")).to be false
      # Would pass, but previous step failed
      expect(@st.click_link("About this site")).to be false
    end

    it "when #click_button fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.click_button("No Such Link")).to be false
      # Would pass, but previous step failed
      expect(@st.click_button("Submit person form")).to be false
    end

    it "when #enable_checkbox fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.enable_checkbox("No Such Checkbox")).to be false
      # Would pass, but previous step failed
      expect(@st.enable_checkbox("I like cheese")).to be false
    end

    it "when #disable_checkbox fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.disable_checkbox("No Such Checkbox")).to be false
      # Would pass, but previous step failed
      expect(@st.disable_checkbox("I like cheese")).to be false
    end

    it "when #checkbox_is_enabled fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.enable_checkbox("I like cheese")).to be true
      expect(@st.checkbox_is_enabled("No Such Checkbox")).to be false
      # Would pass, but previous step failed
      expect(@st.checkbox_is_enabled("I like cheese")).to be false
    end

    it "when #checkbox_is_disabled fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.checkbox_is_disabled("No Such Checkbox")).to be false
      # Would pass, but previous step failed
      expect(@st.checkbox_is_disabled("I like cheese")).to be false
    end

    it "when #radio_is_enabled fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.select_radio("Briefs")).to be true
      expect(@st.radio_is_enabled("No Such Radio")).to be false
      # Would pass, but previous step failed
      expect(@st.radio_is_enabled("Briefs")).to be false
    end

    it "when #radio_is_disabled fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.select_radio("Boxers")).to be true
      expect(@st.radio_is_disabled("No Such Radio")).to be false
      # Would pass, but previous step failed
      expect(@st.radio_is_disabled("Briefs")).to be false
    end

    it "when #select_radio fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.select_radio("No Such Radio")).to be false
      # Would pass, but previous step failed
      expect(@st.select_radio("Boxers")).to be false
    end

    it "when #select_from_dropdown fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.select_from_dropdown("Junk", "No Such Dropdown")).to be false
      # Would pass, but previous step failed
      expect(@st.select_from_dropdown("Tall", "Height")).to be false
    end

    it "when #dropdown_includes fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.dropdown_includes("No Such Dropdown", "Junk")).to be false
      # Would pass, but previous step failed
      expect(@st.dropdown_includes("Height", "Tall")).to be false
    end

    it "when #dropdown_equals fails" do
      expect(@st.visit("/form")).to be true
      expect(@st.select_from_dropdown("Tall", "Height")).to be true
      expect(@st.dropdown_equals("No Such Dropdown", "Junk")).to be false
      # Would pass, but previous step failed
      expect(@st.dropdown_equals("Tall", "Height")).to be false
    end
  end

  context "can be reset with #begin_scenario" do
    it "when #see fails" do
      expect(@st.see("Nonexistent")).to be false
      # Would pass, but previous step failed
      expect(@st.see("Welcome")).to be false
      # Starting a new scenario allows #see to pass
      @st.begin_scenario
      expect(@st.see("Welcome")).to be true
    end

    it "when #do_not_see fails" do
      expect(@st.do_not_see("Welcome")).to be false
      # Would pass, but previous step failed
      expect(@st.do_not_see("Nonexistent")).to be false
      # Starting a new scenario allows #do_not_see to pass
      @st.begin_scenario
      expect(@st.do_not_see("Nonexistent")).to be true
    end
  end

end

