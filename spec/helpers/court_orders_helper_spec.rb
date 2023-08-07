require "rails_helper"

RSpec.describe CourtDatesHelper do
  describe "#court_order_select_options" do
    context "when no court orders" do
      it "empty" do
        expect(helper.court_order_select_options).to eq([["Unimplemented", "unimplemented"], ["Partially implemented", "partially_implemented"], ["Implemented", "implemented"]])
      end
    end
  end
end
