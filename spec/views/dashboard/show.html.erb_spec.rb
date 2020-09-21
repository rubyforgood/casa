require "rails_helper"

describe "dashboard/show", type: :view do
  subject { render template: "dashboard/show" }

  it "renders the admin dashboard" do
    admin = build :casa_admin
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)

    assign :admins, [build_stubbed(:casa_admin).decorate]
    assign :volunteers, [build_stubbed(:volunteer).decorate]
    assign :casa_cases, [build_stubbed(:casa_case).decorate]
    assign :supervisors, [build_stubbed(:supervisor).decorate]

    sign_in admin

    is_expected.to have_selector("#admins")
  end
end
