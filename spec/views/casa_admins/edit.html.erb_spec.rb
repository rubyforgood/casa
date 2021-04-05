require "rails_helper"

RSpec.describe "casa_admins/edit", type: :view do
  let(:admin) { build_stubbed :casa_admin }

  it "shows invite and login info" do
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)

    assign :casa_admin, admin

    render template: "casa_admins/edit"

    expect(rendered).to have_text("Added to system ")
    expect(rendered).to have_text("Invitation email sent \n  never")
    expect(rendered).to have_text("Last logged in")
    expect(rendered).to have_text("Invitation accepted \n  never")
    expect(rendered).to have_text("Password reset last sent \n  never")
  end
end
