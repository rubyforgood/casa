require "rails_helper"

describe "dashboard/show", type: :view do
  context "logged in as an admin" do
    it "renders the admin dashboard partial" do
      admin = build_stubbed :casa_admin
      enable_pundit(view, admin)
      allow(view).to receive(:current_user).and_return(admin)

      assign :volunteers, [build_stubbed(:volunteer).decorate]
      assign :casa_cases, [build_stubbed(:casa_case).decorate]
      assign :supervisors, [build_stubbed(:supervisor).decorate]

      sign_in admin

      render template: "dashboard/show"

      expect(rendered).to have_text("Volunteers")
    end
  end
end
