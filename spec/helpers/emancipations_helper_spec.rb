require "rails_helper"

# Specs in this file have access to a helper object that includes
# the EmancipationsHelper. For example:
#
# describe EmancipationsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe EmancipationsHelper, type: :helper do
  let(:casa_case) { create(:casa_case, transition_aged_youth: true) }
  let(:emancipation_option) { create(:emancipation_option) }

  describe "#emancipation_select_option_selected" do
    it "returns \"selected\" when passed an associated casa case and emancipation option id" do
      create(:casa_cases_emancipation_option, casa_case_id: casa_case.id, emancipation_option_id: emancipation_option.id)
      expect(helper.emancipation_select_option_selected(casa_case, emancipation_option.id)).to eq("selected")
    end

    it "returns nil when passed an unassociated casa case and emancipation option id" do
      expect(helper.emancipation_select_option_selected(casa_case, emancipation_option.id)).to eq(nil)
    end
  end

  describe "#emancipation_checkbox_option_checked" do
    it "returns \"checked\" when passed an associated casa case and emancipation option id" do
      create(:casa_cases_emancipation_option, casa_case_id: casa_case.id, emancipation_option_id: emancipation_option.id)
      expect(helper.emancipation_checkbox_option_checked(casa_case, emancipation_option.id)).to eq("checked")
    end

    it "returns nil when passed an unassociated casa case and emancipation option id" do
      expect(helper.emancipation_checkbox_option_checked(casa_case, emancipation_option.id)).to eq(nil)
    end
  end
end
