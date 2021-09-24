require "rails_helper"

RSpec.describe EmancipationChecklistDownloadHtml do
  describe "#call" do
    it "renders the form correctly" do
      ec1_option_a = create(:emancipation_option, name: "With friend")
      ec1_option_b = create(:emancipation_option, name: "With relative")
      ec1 = create(:emancipation_category, name: "Youth has housing", emancipation_options: [ec1_option_a, ec1_option_b])

      ec2 = create(:emancipation_category, name: "Youth has completed a budget")
      create(:emancipation_category, name: "Youth is employed")

      current_case = create(:casa_case, emancipation_categories: [ec1, ec2], emancipation_options: [ec1_option_a])
      emancipation_form_data = EmancipationCategory.all

      service = described_class.new(current_case, emancipation_form_data)

      str = service.call

      expect(str).to match "With friend"
      expect(str).to match "With relative"
      expect(str).to match "Youth has housing"
      expect(str).to match "Youth has completed a budget"
      expect(str).to match "Youth is employed"
    end
  end
end
