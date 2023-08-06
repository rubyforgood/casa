require "rails_helper"

RSpec.describe "casa_cases/index", type: :view do
  context "when accessed by an admin" do
    it "can see the New Case button" do
      organization = create(:casa_org)
      user = build_stubbed(:casa_admin, casa_org: organization)
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)

      assign :casa_cases, []
      assign :duties, OtherDuty.none

      render template: "casa_cases/index"

      expect(rendered).to have_link "New Case"
    end
  end

  context "when accessed by a supervisor" do
    it "does not see the New Case button" do
      organization = create(:casa_org)
      user = build_stubbed(:supervisor, casa_org: organization)
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)

      assign :casa_cases, []
      assign :duties, OtherDuty.none

      render template: "casa_cases/index"

      expect(rendered).to_not have_link "New Case"
    end
  end
end
