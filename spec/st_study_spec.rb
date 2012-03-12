require 'spec/spec_helper'

describe 'study' do
  before(:all) do
    @st.visit("/form").should be_true
    @st.begin_study.should be_true
  end

  describe "#simplify_studied_xpath" do
    context "does not simplify" do
      it "an id" do
        @st.simplify_studied_xpath('id=first_name').should eq('id=first_name')
      end
      it "a name" do
        @st.simplify_studied_xpath('name=second_duplicate').should eq('name=second_duplicate')
      end
      it "a link" do
        @st.simplify_studied_xpath('link=second duplicate').should eq('link=second duplicate')
      end
      it "a dom path" do
        @st.simplify_studied_xpath('dom=document.links[47]').should eq('dom=document.links[47]')
        @st.simplify_studied_xpath('document.links[47]').should eq('document.links[47]')
      end
    end
    context "simplifies" do
      it "a control to an id" do
        my_xpath = @st.loc('First name')
        @st.simplify_studied_xpath(my_xpath).should eq('id=first_name')
      end
      it "a css path to an id" do
        @st.simplify_studied_xpath('css=#first_name').should eq('id=first_name')
      end
    end
  end
end
