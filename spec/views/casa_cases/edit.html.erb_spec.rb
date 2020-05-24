require "rails_helper"

describe "casa_cases/edit" do
  context "when accessed by a volunteer" do
    it "does not include volunteer assignment" do
      assign :casa_case, create(:casa_case)

      user = build_stubbed(:user, :volunteer)
      allow(view).to receive(:current_user).and_return(user)

      render template: "casa_cases/edit"

      expect(rendered).not_to include("Assign a New Volunteer")
    end
  end

  context "when accessed by an admin" do
    it "includes volunteer assignment" do
      assign :casa_case, create(:casa_case)

      user = build_stubbed(:user, :casa_admin)
      allow(view).to receive(:current_user).and_return(user)

      render template: "casa_cases/edit"

      expect(rendered).to include("Assign a New Volunteer")
    end
  end
end
