require "rails_helper"

RSpec.describe "casa_cases/edit", type: :view do
  let(:organization) { create(:casa_org) }
  let(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
  let(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }

  before do
    enable_pundit(view, user)
    assign :contact_types, []
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "when accessed by a volunteer" do
    let(:user) { build_stubbed(:volunteer, casa_org: organization) }
    let(:casa_case) { create(:casa_case, casa_org: organization) }

    it "does not allow editing the case number" do
      assign :casa_case, casa_case

      render template: "casa_cases/edit"

      expect(rendered).to have_link(casa_case.case_number, href: "/casa_cases/#{casa_case.case_number.parameterize}")
      expect(rendered).to_not have_selector("input[value='#{casa_case.case_number}']")
    end

    it "does not include volunteer assignment" do
      assign :casa_case, casa_case

      render template: "casa_cases/edit"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#volunteer-assignment").length).to eq(0)
    end
  end

  context "when accessed by an admin" do
    let(:user) { build_stubbed(:casa_admin, casa_org: organization) }
    let(:casa_case) { create(:casa_case, casa_org: organization) }

    it "includes an editable case number" do
      assign :casa_case, casa_case
      assign :contact_types, organization.contact_types

      render template: "casa_cases/edit"

      expect(rendered).to have_link(casa_case.case_number, href: "/casa_cases/#{casa_case.case_number.parameterize}")
      expect(rendered).to have_selector("input[value='#{casa_case.case_number}']")
    end

    it "includes volunteer assignment" do
      assign :casa_case, casa_case
      assign :contact_types, organization.contact_types

      render template: "casa_cases/edit"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#volunteer-assignment").length).to eq(1)
    end
  end

  context "when assigning a new volunteer" do
    let(:user) { build_stubbed(:casa_admin, casa_org: organization) }

    it "does not have an option to select a volunteer that is already assigned to the casa case" do
      casa_case = create(:casa_case, casa_org: organization)
      assign :casa_case, casa_case
      assign :contact_types, organization.contact_types
      assigned_volunteer = build_stubbed(:volunteer)
      build_stubbed(:case_assignment, volunteer: assigned_volunteer, casa_case: casa_case)
      unassigned_volunteer = create(:volunteer)

      render template: "casa_cases/edit"

      expect(rendered).to have_select("case_assignment_casa_case_id", options: ["Please Select Volunteer", unassigned_volunteer.display_name])
    end
  end
end
