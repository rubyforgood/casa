require "rails_helper"

RSpec.describe "casa_admins/edit", type: :view do
  describe "does not allow" do
    let(:admin) { build_stubbed :casa_admin }

    it "an admin to edit an admin last sign in" do
      enable_pundit(view, admin)
      allow(view).to receive(:current_user).and_return(admin)

      assign :casa_admin, admin

      render template: "casa_admins/edit"

      expect(rendered).to have_field("casa_admin_last_sign_in_at", disabled: true)
    end
  end
end
