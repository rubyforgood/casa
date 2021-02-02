require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/show", type: :view do
  context "All casa admin organization dashboard" do
    let(:organization) {create :casa_org }
  
    let(:org_info) {
      [
        {
          type: :casa_admin,
          number: 3,
          active: true,
          description: "admin",
        },
        {
          type: :supervisor,
          number: 7,
          active: true,
          description: "supervisor",
        },
        {
          type: :volunteer,
          number: 20,
          active: true,
          description: "active volunteer",
        },
        {
          type: :volunteer,
          number: 7,
          active: false,
          description: "inactive volunteer",
        },
        {
          type: :casa_case,
          number: 50,
          active: true,
          description: "active case",
        },
        {
          type: :casa_case,
          number: 11,
          active: false,
          description: "inactive case",
        },
      ]
    }

    before do
      # seed the organization
      org_info.each do |group|
        group[:number].times do
          create group[:type], casa_org: organization, active: group[:active]
        end
      end
      allow(view).to receive(:selected_organization).and_return(organization)
      render
    end

    it "shows stats about the organization" do
      org_info.each do |group|
        expect(rendered).to have_text(
          "Number of #{group[:description]}s: #{group[:number]}",
          normalize_ws: true,
        )
      end
    end
  end
end