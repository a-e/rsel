require_relative 'wt_spec_helper'

describe 'tables' do
  before(:each) do
    @wt.visit("/table").should be_true
  end

  describe "#row_exists" do
    context "passes when" do
      it "full row of headings exists" do
        @wt.row_exists("First name, Last name, Email").should be_true
      end

      it "partial row of headings exists" do
        @wt.row_exists("First name, Last name").should be_true
        @wt.row_exists("Last name, Email").should be_true
      end

      it "full row of cells exists" do
        @wt.row_exists("Eric, Pierce, epierce@example.com").should be_true
      end

      it "partial row of cells exists" do
        @wt.row_exists("Eric, Pierce").should be_true
        @wt.row_exists("Pierce, epierce@example.com").should be_true
      end

      it "cell values are not consecutive" do
        @wt.row_exists("First name, Email").should be_true
        @wt.row_exists("Eric, epierce@example.com").should be_true
      end
    end

    context "fails when" do
      it "no row exists" do
        @wt.row_exists("Middle name, Maiden name, Email").should be_false
      end
    end
  end

end

