require "rails_helper"

RSpec.describe "casa_cases/index", type: :view do
  context "when accessed by a volunteer" do
    it "can not see the Assigned To column" do
      user = create(:volunteer, display_name: "Bob Loblaw")
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)

      casa_case = build(:casa_case, active: true, casa_org: user.casa_org, case_number: "CINA-1")
      create(:case_assignment, volunteer: user, casa_case: casa_case)
      assign :casa_cases, [casa_case]
      assign :duties, OtherDuty.none

      render template: "casa_cases/index"

      expect(rendered).not_to have_text "Assigned To"
      expect(rendered).not_to have_text("Bob Loblaw")
    end
  end

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

  context "When SHOW_OTHER_DUTIES_FLAG disabled" do
    it "does not see the New Duty button" do
      organization = create(:casa_org)
      user = build_stubbed(:supervisor, casa_org: organization)
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      FeatureFlagService.disable!("show_other_duties")

      assign :casa_cases, []
      assign :duties, OtherDuty.none

      render template: "casa_cases/index"

      expect(rendered).to_not have_link "New Duty"
    end
  end

  context "When SHOW_OTHER_DUTIES_FLAG enabled" do
    it "shows the New Duty button" do
      organization = create(:casa_org)
      user = build_stubbed(:supervisor, casa_org: organization)
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      FeatureFlagService.enable!("show_other_duties")

      assign :casa_cases, []
      assign :duties, OtherDuty.none

      render template: "casa_cases/index"

      expect(rendered).to have_link "New Duty"
    end
  end
end
