require_relative 'wt_spec_helper'

describe 'stop on failure' do
  before(:each) do
    @wt.visit("/").should be_true
    @wt.stop_on_failure = true
    @wt.found_failure = false
  end

  after(:each) do
    @wt.stop_on_failure = false
  end

  context "causes subsequent steps to fail" do
    it "when #see fails" do
      @wt.see("Nonexistent").should be_false
      # Would pass, but previous step failed
      @wt.see("Welcome").should be_false
    end

    it "when #do_not_see fails" do
      @wt.do_not_see("Welcome").should be_false
      # Would pass, but previous step failed
      @wt.do_not_see("Nonexistent").should be_false
    end

    it "when #see_title fails" do
      @wt.errors # clear errors
      @wt.see_title("Wrong Title").should be_false
      # Would pass, but previous step failed
      @wt.see_title("Rsel Test Site").should be_false
      # Should see one and only one error.
      @wt.errors.should eq("Page title is 'Rsel Test Site', not 'Wrong Title'")
    end

    it "when #do_not_see_title fails" do
      @wt.do_not_see_title("Rsel Test Site").should be_false
      # Would pass, but previous step failed
      @wt.do_not_see_title("Wrong title").should be_false
    end

    it "when #link_exists fails" do
      @wt.link_exists("Bogus Link").should be_false
      # Would pass, but previous step failed
      @wt.link_exists("About this site").should be_false
    end

    it "when #button_exists fails" do
      @wt.visit("/form").should be_true
      @wt.button_exists("Bogus Button").should be_false
      # Would pass, but previous step failed
      @wt.button_exists("Submit person form").should be_false
    end

    it "when #row_exists fails" do
      @wt.visit("/table").should be_true
      @wt.row_exists("No, Such, Row").should be_false
      # Would pass, but previous step failed
      @wt.row_exists("First name, Last name, Email").should be_false
    end

    it "when #type_into_field fails" do
      @wt.visit("/form").should be_true
      @wt.type_into_field("Hello", "Bad Field").should be_false
      # Would pass, but previous step failed
      @wt.type_into_field("Eric", "First name").should be_false
    end

    it "when #field_contains fails" do
      @wt.visit("/form").should be_true
      @wt.field_contains("Bad Field", "Hello").should be_false
      # Would pass, but previous step failed
      @wt.field_contains("First name", "Marcus").should be_false
    end

    it "when #field_equals fails" do
      @wt.visit("/form").should be_true
      @wt.fill_in_with("First name", "Ken")
      @wt.field_equals("First name", "Eric").should be_false
      # Would pass, but previous step failed
      @wt.field_equals("First name", "Ken").should be_false
    end

    it "when #click fails" do
      @wt.click("No Such Link").should be_false
      # Would pass, but previous step failed
      @wt.click("About this site").should be_false
    end

    it "when #click_link fails" do
      @wt.click_link("No Such Link").should be_false
      # Would pass, but previous step failed
      @wt.click_link("About this site").should be_false
    end

    it "when #click_button fails" do
      @wt.visit("/form").should be_true
      @wt.click_button("No Such Link").should be_false
      # Would pass, but previous step failed
      @wt.click_button("Submit person form").should be_false
    end

    it "when #enable_checkbox fails" do
      @wt.visit("/form").should be_true
      @wt.enable_checkbox("No Such Checkbox").should be_false
      # Would pass, but previous step failed
      @wt.enable_checkbox("I like cheese").should be_false
    end

    it "when #disable_checkbox fails" do
      @wt.visit("/form").should be_true
      @wt.disable_checkbox("No Such Checkbox").should be_false
      # Would pass, but previous step failed
      @wt.disable_checkbox("I like cheese").should be_false
    end

    it "when #checkbox_is_enabled fails" do
      @wt.visit("/form").should be_true
      @wt.enable_checkbox("I like cheese").should be_true
      @wt.checkbox_is_enabled("No Such Checkbox").should be_false
      # Would pass, but previous step failed
      @wt.checkbox_is_enabled("I like cheese").should be_false
    end

    it "when #checkbox_is_disabled fails" do
      @wt.visit("/form").should be_true
      @wt.checkbox_is_disabled("No Such Checkbox").should be_false
      # Would pass, but previous step failed
      @wt.checkbox_is_disabled("I like cheese").should be_false
    end

    it "when #radio_is_enabled fails" do
      @wt.visit("/form").should be_true
      @wt.select_radio("Briefs").should be_true
      @wt.radio_is_enabled("No Such Radio").should be_false
      # Would pass, but previous step failed
      @wt.radio_is_enabled("Briefs").should be_false
    end

    it "when #radio_is_disabled fails" do
      @wt.visit("/form").should be_true
      @wt.select_radio("Boxers").should be_true
      @wt.radio_is_disabled("No Such Radio").should be_false
      # Would pass, but previous step failed
      @wt.radio_is_disabled("Briefs").should be_false
    end

    it "when #select_radio fails" do
      @wt.visit("/form").should be_true
      @wt.select_radio("No Such Radio").should be_false
      # Would pass, but previous step failed
      @wt.select_radio("Boxers").should be_false
    end

    it "when #select_from_dropdown fails" do
      @wt.visit("/form").should be_true
      @wt.select_from_dropdown("Junk", "No Such Dropdown").should be_false
      # Would pass, but previous step failed
      @wt.select_from_dropdown("Tall", "Height").should be_false
    end

    it "when #dropdown_includes fails" do
      @wt.visit("/form").should be_true
      @wt.dropdown_includes("No Such Dropdown", "Junk").should be_false
      # Would pass, but previous step failed
      @wt.dropdown_includes("Height", "Tall").should be_false
    end

    it "when #dropdown_equals fails" do
      @wt.visit("/form").should be_true
      @wt.select_from_dropdown("Tall", "Height").should be_true
      @wt.dropdown_equals("No Such Dropdown", "Junk").should be_false
      # Would pass, but previous step failed
      @wt.dropdown_equals("Tall", "Height").should be_false
    end
  end

  context "can be reset with #begin_scenario" do
    it "when #see fails" do
      @wt.see("Nonexistent").should be_false
      # Would pass, but previous step failed
      @wt.see("Welcome").should be_false
      # Starting a new scenario allows #see to pass
      @wt.begin_scenario
      @wt.see("Welcome").should be_true
    end

    it "when #do_not_see fails" do
      @wt.do_not_see("Welcome").should be_false
      # Would pass, but previous step failed
      @wt.do_not_see("Nonexistent").should be_false
      # Starting a new scenario allows #do_not_see to pass
      @wt.begin_scenario
      @wt.do_not_see("Nonexistent").should be_true
    end
  end

end

