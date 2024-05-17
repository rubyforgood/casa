require "rails_helper"

RSpec.describe ReportHelper do
  describe "#boolean_choices" do
    it "returns array with correct options" do
      expect(helper.boolean_choices).to eq [["Both", ""], ["Yes", true], ["No", false]]
    end
  end
end
