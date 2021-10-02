require "rails_helper"

# config/initializers/core_extensions.rb

RSpec.describe String do
  describe "#to_boolean" do
    context "when self is not equal 'true' (case_insensitive)" do
      it "returns false", :aggregate_failures do
        expect("false".to_boolean).to eq(false)
        expect("FALSE".to_boolean).to eq(false)
        expect("AnoTher-sTring".to_boolean).to eq(false)
      end
    end

    context "when self is equal 'true' (case_insensitive)" do
      it "returns true", :aggregate_failures do
        expect("true".to_boolean).to eq(true)
        expect("TRUE".to_boolean).to eq(true)
      end
    end
  end
end
