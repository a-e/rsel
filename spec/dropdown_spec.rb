require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rsel::SeleniumTest, 'dropdown' do
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



