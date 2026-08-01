require "rails_helper"

RSpec.describe "admins_table", type: :view do
  it "allows editing admin users" do
    admin = build_stubbed :casa_admin
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
    # See mileage_rates/index spec: an unstubbed org-scoped helper recurses to SystemStackError in a
    # view spec rather than raising, because helper_method routes it back through the example group.
    allow(view).to receive(:current_organization).and_return(admin.casa_org)

    assign :admins, [admin.decorate]

    sign_in admin

    render template: "casa_admins/index"

    expect(rendered).to have_link("Edit", href: "/casa_admins/#{admin.id}/edit")
  end
end
