require "rails_helper"

RSpec.describe "placements/edit", type: :view do
  subject { render template: "placements/edit" }

  let(:organization) { create(:casa_org) }
  let(:user) { build_stubbed(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization, case_number: "123") }
  let(:placement_type) { create(:placement_type, name: "Reunification") }
  let(:placement) { create(:placement, placement_started_at: "2024-08-15 12:39:00 UTC", placement_type:, casa_case:) }

  before do
    assign :casa_case, casa_case
    assign :placement, placement

    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
    render
  end

  it "has 'edit' heading and inputs for started at and type with the correct values" do
    expect(rendered).to have_css("h1", text: "Editing Placement")
    expect(rendered).to have_field("placement[placement_started_at]", with: "2024-08-15")
    expect(rendered).to have_select("placement[placement_type_id]", with_options: ["-Select Placement Type-"])
  end
end
