require "rails_helper"

describe "dashboard/admins_table", type: :view do
  it "allows editing admin users" do
    admin = build_stubbed :casa_admin
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)

    assign :admins, [admin.decorate]
    assign :volunteers, [build_stubbed(:volunteer).decorate]
    assign :casa_cases, [build_stubbed(:casa_case).decorate]
    assign :supervisors, [build_stubbed(:supervisor).decorate]

    sign_in admin

    render partial: "dashboard/admins_table"

    expect(rendered).to have_link("Edit", href: "/casa_admins/#{admin.id}/edit")
  end
end
