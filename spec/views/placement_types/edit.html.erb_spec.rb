require "rails_helper"

RSpec.describe "placement_types/edit.html.erb", type: :view do
  let(:organization) { build_stubbed :casa_org }
  let(:admin) { build_stubbed :casa_admin, casa_org: organization }
  let(:placement_type) { build_stubbed :placement_type, casa_org: organization }

  before do
    enable_pundit(view, admin)
    sign_in admin
  end

  it "allows editing the placement type" do
    assign :placement_type, placement_type
    render template: "placement_types/edit"
    expect(rendered).to have_text("Edit Placement Type")
    expect(rendered).to have_field("placement_type[name]", with: placement_type.name)
    expect(rendered).to have_button("Submit")
  end
end
