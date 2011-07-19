require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest, 'checkbox' do
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
