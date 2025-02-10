require "rails_helper"

RSpec.describe ReportHelper, type: :helper do
  describe "#boolean_choices" do
    it "returns array with correct options" do
      expect(helper.boolean_choices).to eq [["Both", ""], ["Yes", true], ["No", false]]
    end
  end
end
