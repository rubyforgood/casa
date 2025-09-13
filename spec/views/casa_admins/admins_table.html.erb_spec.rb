require "rails_helper"

RSpec.describe "admins_table", type: :view do
  it "allows editing admin users" do
    admin = build_stubbed :casa_admin
    enable_pundit(view, admin)

    assign :admins, [admin.decorate]

    sign_in admin

    render template: "casa_admins/index"

    expect(rendered).to have_link("Edit", href: "/casa_admins/#{admin.id}/edit")
  end
end
