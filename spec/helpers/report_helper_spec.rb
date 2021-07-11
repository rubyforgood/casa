require "rails_helper"

RSpec.describe ReportHelper do
  describe "#boolean_choices" do
    it "returns array with correct options" do
      expect(helper.boolean_choices).to eq [[I18n.t(".common.both_text"), ""], [I18n.t(".common.yes_text"), true], [I18n.t(".common.no_text"), false]]
    end
  end
end
