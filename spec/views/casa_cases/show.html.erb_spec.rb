require "rails_helper"

RSpec.describe "casa_cases/show", type: :view do
  let(:organization) { create(:casa_org) }

  before do
    enable_pundit(view, user)
    assign :contact_types, []
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "when accessed by an admin" do
    let(:user) { build_stubbed(:casa_admin, casa_org: organization) }

    it "includes case court mandates" do
      casa_case = create(
        :casa_case,
        :with_case_assignments,
        :with_one_court_mandate
      )
      assign :casa_case, casa_case

      module MockPundit
        def policy_scope(scope)
          @casa_case.assigned_volunteers
        end
      end

      view.class.include MockPundit

      allow(view).to receive(:params).and_return({id: casa_case.id})

      render template: "casa_cases/show"

      expect(rendered).to include("Court Mandates")
      expect(rendered).to include(casa_case.case_court_mandates[0].mandate_text)
    end
  end
end
