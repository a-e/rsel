require_relative 'st_spec_helper'

describe 'tables' do
  before(:each) do
    expect(@st.visit("/table")).to be true
  end

  describe "#row_exists" do
    context "passes when" do
      it "full row of headings exists" do
        expect(@st.row_exists("First name, Last name, Email")).to be true
      end

      it "partial row of headings exists" do
        expect(@st.row_exists("First name, Last name")).to be true
        expect(@st.row_exists("Last name, Email")).to be true
      end

      it "full row of cells exists" do
        expect(@st.row_exists("Eric, Pierce, epierce@example.com")).to be true
      end

      it "partial row of cells exists" do
        expect(@st.row_exists("Eric, Pierce")).to be true
        expect(@st.row_exists("Pierce, epierce@example.com")).to be true
      end

      it "cell values are not consecutive" do
        expect(@st.row_exists("First name, Email")).to be true
        expect(@st.row_exists("Eric, epierce@example.com")).to be true
      end
    end

    context "fails when" do
      it "no row exists" do
        expect(@st.row_exists("Middle name, Maiden name, Email")).to be false
      end
    end
  end

end

