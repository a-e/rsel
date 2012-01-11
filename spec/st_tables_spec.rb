require 'spec/spec_helper'

describe 'tables' do
  before(:each) do
    @st.visit("/table").should be_true
  end

  describe "#row_exists" do
    context "passes when" do
      it "full row of headings exists" do
        @st.row_exists("First name, Last name, Email").should be_true
      end

      it "partial row of headings exists" do
        @st.row_exists("First name, Last name").should be_true
        @st.row_exists("Last name, Email").should be_true
      end

      it "full row of cells exists" do
        @st.row_exists("Eric, Pierce, epierce@example.com").should be_true
      end

      it "partial row of cells exists" do
        @st.row_exists("Eric, Pierce").should be_true
        @st.row_exists("Pierce, epierce@example.com").should be_true
      end

      it "cell values are not consecutive" do
        @st.row_exists("First name, Email").should be_true
        @st.row_exists("Eric, epierce@example.com").should be_true
      end
    end

    context "fails when" do
      it "no row exists" do
        @st.row_exists("Middle name, Maiden name, Email").should be_false
      end
    end
  end

end

