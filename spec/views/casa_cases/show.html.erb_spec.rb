require "rails_helper"

RSpec.describe "casa_cases/show", type: :view do
  let(:organization) { create(:casa_org) }

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "when the URL contains ?success=true" do
    let(:user) { build_stubbed(:volunteer, casa_org: organization) }
    let(:casa_case) { create(:casa_case, casa_org: organization) }

    before do
      allow_any_instance_of(ApplicationHelper).to receive(:contains_success_param?).and_return(true)
    end

    it "renders thank you modal" do
      assign :casa_case, casa_case
      render

      expect(rendered).to match /"thank-you-modal-wrapper"/
    end
  end

  context "when the URL does not contain ?success=true" do
    let(:user) { build_stubbed(:volunteer, casa_org: organization) }
    let(:casa_case) { create(:casa_case, casa_org: organization) }

    it "does not render thank you modal" do
      assign :casa_case, casa_case
      render

      expect(rendered).not_to match /"thank-you-modal-wrapper"/
    end
  end
end
