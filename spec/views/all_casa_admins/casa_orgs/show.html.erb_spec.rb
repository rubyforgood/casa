require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/show", type: :view do
  context "All casa admin organization dashboard" do
    let(:organization) { create :casa_org }
    let(:user) { create(:all_casa_admin) }

    let(:org_info) {
      [
        {
          type: :casa_admin,
          number: 3,
          active: true,
          description: "admin"
        },
        {
          type: :supervisor,
          number: 7,
          active: true,
          description: "supervisor"
        },
        {
          type: :volunteer,
          number: 20,
          active: true,
          description: "active volunteer"
        },
        {
          type: :volunteer,
          number: 7,
          active: false,
          description: "inactive volunteer"
        },
        {
          type: :casa_case,
          number: 50,
          active: true,
          description: "active case"
        },
        {
          type: :casa_case,
          number: 11,
          active: false,
          description: "inactive case"
        },
        {
          type: :case_assignment,
          number: 1,
          active: true,
          description: "all case contacts including inactive"
        },
        {
          type: :supervisor_volunteer,
          number: 2,
          active: true,
          description: "supervisor to volunteer assignment"
        },
        {
          type: :case_assignment,
          number: 3,
          active: true,
          description: "active case assingments"
        }
      ]
    }

    # context "Volunteer views 'Generate Court Report' form" do
    #   let(:user) { create(:volunteer, :with_casa_cases) }
    #   let(:active_assigned_cases) { CasaCase.actively_assigned_to(user) }
    #
    #   before do
    #     allow(view).to receive(:current_user).and_return(user)
    #     assign :assigned_cases, active_assigned_cases
    #     render
    #   end
    # create :case_assignment, volunteer: (create :volunteer, casa_org: organization)



    before do
      # seed the organization
      org_info.each do |group|
        group[:number].times do
          p group
          if group[:type] == :case_assignment
            p organization
            create group[:type], is_active: group[:active], volunteer: (create :volunteer, casa_org: organization)
          elsif (group[:type] == :supervisor_volunteer)
            create :supervisor_volunteer, is_active: group[:active], volunteer: (create :volunteer, casa_org: organization), supervisor: (create :supervisor, casa_org: organization)
          else
            create group[:type], active: group[:active]
          end
        end
      end
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:selected_organization).and_return(organization)
      render
    end

    it "shows stats about the organization" do
      org_info.each do |group|
        expect(rendered).to have_text(
          "Number of #{group[:description]}s: #{group[:number]}",
          normalize_ws: true
        )
      end
    end
  end
end
