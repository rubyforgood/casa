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
  let(:casa_case) { create(:casa_case) }

  describe "#emancipation_category_checkbox_checked" do
    let(:emancipation_category) { create(:emancipation_category, name: "unique name") }

    it "returns \"checked\" when passed an associated casa case and emancipation category" do
      create(:casa_case_emancipation_category, casa_case_id: casa_case.id, emancipation_category_id: emancipation_category.id)
      expect(helper.emancipation_category_checkbox_checked(casa_case, emancipation_category)).to eq("checked")
    end

    it "returns nil when passed an unassociated casa case and emancipation category" do
      expect(helper.emancipation_category_checkbox_checked(casa_case, emancipation_category)).to eq(nil)
    end
  end

  describe "#emancipation_category_collapse_hidden" do
    let(:emancipation_category) { create(:emancipation_category, name: "another unique name") }

    it "returns nil when passed an associated casa case and emancipation category" do
      create(:casa_case_emancipation_category, casa_case_id: casa_case.id, emancipation_category_id: emancipation_category.id)
      expect(helper.emancipation_category_collapse_hidden(casa_case, emancipation_category)).to eq(nil)
    end

    it "returns \"display: none;\" when passed an unassociated casa case and emancipation category" do
      expect(helper.emancipation_category_collapse_hidden(casa_case, emancipation_category)).to eq("display: none;")
    end
  end

  describe "#emancipation_category_collapse_icon" do
    let(:emancipation_category) { create(:emancipation_category, name: "another unique name") }

    it "returns nil when passed an associated casa case and emancipation category" do
      create(:casa_case_emancipation_category, casa_case_id: casa_case.id, emancipation_category_id: emancipation_category.id)
      expect(helper.emancipation_category_collapse_icon(casa_case, emancipation_category)).to eq("−")
    end

    it "returns \"display: none;\" when passed an unassociated casa case and emancipation category" do
      expect(helper.emancipation_category_collapse_icon(casa_case, emancipation_category)).to eq("+")
    end
  end

  describe "#emancipation_option_checkbox_checked" do
    let(:emancipation_option) { create(:emancipation_option) }

    it "returns \"checked\" when passed an associated casa case and emancipation option" do
      create(:casa_cases_emancipation_option, casa_case_id: casa_case.id, emancipation_option_id: emancipation_option.id)
      expect(helper.emancipation_option_checkbox_checked(casa_case, emancipation_option)).to eq("checked")
    end

    it "returns nil when passed an unassociated casa case and emancipation option id" do
      expect(helper.emancipation_option_checkbox_checked(casa_case, emancipation_option)).to eq(nil)
    end
  end
end
