require "rails_helper"

RSpec.describe "casa_cases/new", type: :view do
  let(:casa_org) { create(:casa_org) }
  let(:user) { create(:casa_admin, casa_org: casa_org) }
  let(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
  let(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }

  context "while signed in as admin" do
    it "has youth birth month and year" do
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_organization).and_return(casa_org)

      assign :casa_case, build(:casa_case, casa_org: casa_org)
      assign :contact_types, casa_org.contact_types

      render template: "casa_cases/new"

      expect(rendered).to have_content("Youth's birth month and year")
    end
  end

  context "when trying to assign a volunteer to a case" do
    it "is able to assign volunteers" do
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_organization).and_return(user.casa_org)

      assign :casa_case, build(:casa_case, casa_org: user.casa_org)
      assign :contact_types, casa_org.contact_types

      render template: "casa_cases/new"

      expect(rendered).to have_content("Assign a volunteer")
      expect(rendered).to have_css("#casa_case_case_assignments_attributes_0_volunteer_id")
    end
  end

  context "court date toggle" do
    before do
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_organization).and_return(casa_org)

      assign :casa_case, build(:casa_case, casa_org: casa_org)
      assign :contact_types, casa_org.contact_types
    end

    it "starts the court date hidden when the court date is unknown" do
      assign :empty_court_date, true

      render template: "casa_cases/new"

      expect(rendered).to have_css("#casa_case_court_dates_attributes_0_date.hidden", visible: :all)
    end

    it "shows the court date when the court date is known" do
      assign :empty_court_date, false

      render template: "casa_cases/new"

      expect(rendered).to have_css("#casa_case_court_dates_attributes_0_date", visible: :all)
      expect(rendered).not_to have_css("#casa_case_court_dates_attributes_0_date.hidden", visible: :all)
    end

    it "wires the court date toggle to the reveal controller" do
      render template: "casa_cases/new"

      expect(rendered).to have_css("[data-controller='reveal'][data-reveal-hidden-class='hidden']")
      expect(rendered).to have_css("#casa_case_court_dates_attributes_0_date[data-reveal-target='item']", visible: :all)
      expect(rendered).to have_css("#casa_case_empty_court_date[data-action='click->reveal#toggle'][autocomplete='off']", visible: :all)
    end
  end
end
