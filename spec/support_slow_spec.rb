require_relative 'spec_helper'

require 'xpath'

# Slow-running support specs
describe Rsel::Support do
  describe "#result_within" do
    context "returns the result when" do
      it "block evaluates to true immediately" do
        result = result_within(3) { true }
        expect(result).to be true
      end

      it "block evaluates to a non-false value immediately" do
        result = result_within(3) { foo = 'foo' }
        expect(result).to eq 'foo'
      end

      it "block evaluates to false initially, but true within the timeout" do
        @first_run = true
        result = result_within(3) {
          if @first_run
            @first_run = false
            false
          else
            true
          end
        }
        expect(result).to be true
      end

      it "block raises an exception, but evaluates true within the timeout" do
        @first_run = true
        result = result_within(3) {
          if @first_run
            @first_run = false
            raise RuntimeError
          else
            true
          end
        }
        expect(result).to be true
      end
    end

    context "returns nil when" do
      it "block evaluates as false every time" do
        result = result_within(3) { false }
        expect(result).to be nil
      end

      it "block evaluates as nil every time" do
        result = result_within(3) { nil }
        expect(result).to be nil
      end

      it "block raises an exception every time" do
        result = result_within(3) { raise RuntimeError }
        expect(result).to be nil
      end

      it "block does not return within the timeout"
    end
  end


  describe "#failed_within" do
    context "returns true when" do
      it "block evaluates to false immediately" do
        result = failed_within(3) { false }
        expect(result).to be true
      end

      it "block evaluates to nil immediately" do
        result = failed_within(3) { nil }
        expect(result).to be true
      end

      it "block evaluates to true initially, but false within the timeout" do
        @first_run = true
        result = failed_within(3) {
          if @first_run
            @first_run = false
            true
          else
            false
          end
        }
        expect(result).to be true
      end

      it "block evaluates to true initially, but raises an exception within the timeout" do
        @first_run = true
        result = failed_within(3) {
          if @first_run
            @first_run = false
            true
          else
            raise RuntimeError
          end
        }
        expect(result).to be true
      end
    end

    context "returns false when" do
      it "block evaluates as true every time" do
        result = failed_within(3) { true }
        expect(result).to be false
      end

      it "block evaluates as true-ish every time" do
        result = failed_within(3) { 'foo' }
        expect(result).to be false
      end
    end
  end
end
