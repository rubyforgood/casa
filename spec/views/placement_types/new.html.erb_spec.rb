require "rails_helper"

RSpec.describe "placement_types/new.html.erb", type: :view do
  let(:organization) { build_stubbed :casa_org }
  let(:admin) { build_stubbed :casa_admin, casa_org: organization }
  let(:placement_type) { organization.placement_types.new }

  before do
    enable_pundit(view, admin)
    sign_in admin
  end

  it "allows creating a placement type" do
    assign :placement_type, placement_type
    render template: "placement_types/new"
    expect(rendered).to have_text("New Placement Type")
    expect(rendered).to have_field("placement_type[name]")
    expect(rendered).to have_button("Submit")
  end
end
