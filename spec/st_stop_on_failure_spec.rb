require 'spec/st_spec_helper'

describe 'stop on failure' do
  before(:each) do
    @st.visit("/").should be_true
    @st.stop_on_failure = true
    @st.found_failure = false
  end

  after(:each) do
    @st.stop_on_failure = false
  end

  context "causes subsequent steps to fail" do
    it "when #see fails" do
      @st.see("Nonexistent").should be_false
      # Would pass, but previous step failed
      @st.see("Welcome").should be_false
    end

    it "when #do_not_see fails" do
      @st.do_not_see("Welcome").should be_false
      # Would pass, but previous step failed
      @st.do_not_see("Nonexistent").should be_false
    end

    it "when #see_title fails" do
      @st.errors # clear errors
      @st.see_title("Wrong Title").should be_false
      # Would pass, but previous step failed
      @st.see_title("Rsel Test Site").should be_false
      # Should see one and only one error.
      @st.errors.should eq("Page title is 'Rsel Test Site', not 'Wrong Title'")
    end

    it "when #do_not_see_title fails" do
      @st.do_not_see_title("Rsel Test Site").should be_false
      # Would pass, but previous step failed
      @st.do_not_see_title("Wrong title").should be_false
    end

    it "when #link_exists fails" do
      @st.link_exists("Bogus Link").should be_false
      # Would pass, but previous step failed
      @st.link_exists("About this site").should be_false
    end

    it "when #button_exists fails" do
      @st.visit("/form").should be_true
      @st.button_exists("Bogus Button").should be_false
      # Would pass, but previous step failed
      @st.button_exists("Submit person form").should be_false
    end

    it "when #row_exists fails" do
      @st.visit("/table").should be_true
      @st.row_exists("No, Such, Row").should be_false
      # Would pass, but previous step failed
      @st.row_exists("First name, Last name, Email").should be_false
    end

    it "when #type_into_field fails" do
      @st.visit("/form").should be_true
      @st.type_into_field("Hello", "Bad Field").should be_false
      # Would pass, but previous step failed
      @st.type_into_field("Eric", "First name").should be_false
    end

    it "when #field_contains fails" do
      @st.visit("/form").should be_true
      @st.field_contains("Bad Field", "Hello").should be_false
      # Would pass, but previous step failed
      @st.field_contains("First name", "Marcus").should be_false
    end

    it "when #field_equals fails" do
      @st.visit("/form").should be_true
      @st.fill_in_with("First name", "Ken")
      @st.field_equals("First name", "Eric").should be_false
      # Would pass, but previous step failed
      @st.field_equals("First name", "Ken").should be_false
    end

    it "when #click fails" do
      @st.click("No Such Link").should be_false
      # Would pass, but previous step failed
      @st.click("About this site").should be_false
    end

    it "when #click_link fails" do
      @st.click_link("No Such Link").should be_false
      # Would pass, but previous step failed
      @st.click_link("About this site").should be_false
    end

    it "when #click_button fails" do
      @st.visit("/form").should be_true
      @st.click_button("No Such Link").should be_false
      # Would pass, but previous step failed
      @st.click_button("Submit person form").should be_false
    end

    it "when #enable_checkbox fails" do
      @st.visit("/form").should be_true
      @st.enable_checkbox("No Such Checkbox").should be_false
      # Would pass, but previous step failed
      @st.enable_checkbox("I like cheese").should be_false
    end

    it "when #disable_checkbox fails" do
      @st.visit("/form").should be_true
      @st.disable_checkbox("No Such Checkbox").should be_false
      # Would pass, but previous step failed
      @st.disable_checkbox("I like cheese").should be_false
    end

    it "when #checkbox_is_enabled fails" do
      @st.visit("/form").should be_true
      @st.enable_checkbox("I like cheese").should be_true
      @st.checkbox_is_enabled("No Such Checkbox").should be_false
      # Would pass, but previous step failed
      @st.checkbox_is_enabled("I like cheese").should be_false
    end

    it "when #checkbox_is_disabled fails" do
      @st.visit("/form").should be_true
      @st.checkbox_is_disabled("No Such Checkbox").should be_false
      # Would pass, but previous step failed
      @st.checkbox_is_disabled("I like cheese").should be_false
    end

    it "when #radio_is_enabled fails" do
      @st.visit("/form").should be_true
      @st.select_radio("Briefs").should be_true
      @st.radio_is_enabled("No Such Radio").should be_false
      # Would pass, but previous step failed
      @st.radio_is_enabled("Briefs").should be_false
    end

    it "when #radio_is_disabled fails" do
      @st.visit("/form").should be_true
      @st.select_radio("Boxers").should be_true
      @st.radio_is_disabled("No Such Radio").should be_false
      # Would pass, but previous step failed
      @st.radio_is_disabled("Briefs").should be_false
    end

    it "when #select_radio fails" do
      @st.visit("/form").should be_true
      @st.select_radio("No Such Radio").should be_false
      # Would pass, but previous step failed
      @st.select_radio("Boxers").should be_false
    end

    it "when #select_from_dropdown fails" do
      @st.visit("/form").should be_true
      @st.select_from_dropdown("Junk", "No Such Dropdown").should be_false
      # Would pass, but previous step failed
      @st.select_from_dropdown("Tall", "Height").should be_false
    end

    it "when #dropdown_includes fails" do
      @st.visit("/form").should be_true
      @st.dropdown_includes("No Such Dropdown", "Junk").should be_false
      # Would pass, but previous step failed
      @st.dropdown_includes("Height", "Tall").should be_false
    end

    it "when #dropdown_equals fails" do
      @st.visit("/form").should be_true
      @st.select_from_dropdown("Tall", "Height").should be_true
      @st.dropdown_equals("No Such Dropdown", "Junk").should be_false
      # Would pass, but previous step failed
      @st.dropdown_equals("Tall", "Height").should be_false
    end
  end

  context "can be reset with #begin_scenario" do
    it "when #see fails" do
      @st.see("Nonexistent").should be_false
      # Would pass, but previous step failed
      @st.see("Welcome").should be_false
      # Starting a new scenario allows #see to pass
      @st.begin_scenario
      @st.see("Welcome").should be_true
    end

    it "when #do_not_see fails" do
      @st.do_not_see("Welcome").should be_false
      # Would pass, but previous step failed
      @st.do_not_see("Nonexistent").should be_false
      # Starting a new scenario allows #do_not_see to pass
      @st.begin_scenario
      @st.do_not_see("Nonexistent").should be_true
    end
  end

end

