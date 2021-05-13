require "rails_helper"

RSpec.describe "volunteers/edit", :disable_bullet, type: :view do
  let(:volunteer) { create :volunteer }

  it "allows an administrator to edit a volunteers email address" do
    administrator = build_stubbed :casa_admin
    enable_pundit(view, administrator)
    allow(view).to receive(:current_user).and_return(administrator)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to_not have_field("volunteer_email", readonly: true)
  end

  it "allows a supervisor to edit a volunteers email address" do
    supervisor = build_stubbed :supervisor
    enable_pundit(view, supervisor)
    allow(view).to receive(:current_user).and_return(supervisor)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to_not have_field("volunteer_email", readonly: true)
  end

  it "does not allow a supervisor to edit a volunteers email address" do
    supervisor = build_stubbed :supervisor
    enable_pundit(view, supervisor)
    allow(view).to receive(:current_user).and_return(supervisor)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to_not have_field("volunteer_email", readonly: true)
  end

  it "shows invite and login info" do
    supervisor = build_stubbed :supervisor
    enable_pundit(view, supervisor)
    allow(view).to receive(:current_user).and_return(supervisor)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to have_text("Added to system ")
    expect(rendered).to have_text("Invitation email sent \n  never")
    expect(rendered).to have_text("Last logged in")
    expect(rendered).to have_text("Invitation accepted \n  never")
    expect(rendered).to have_text("Password reset last sent \n  never")
  end

  context " the user has requested to reset their password" do
    describe "shows resend invitation "
    let(:volunteer) { create :volunteer }
    let(:supervisor) { build_stubbed :supervisor }
    let(:admin) { build_stubbed :casa_admin }

    it "allows an administrator resend invitation to a volunteer" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(admin)

      assign :volunteer, volunteer
      assign :supervisors, []

      render template: "volunteers/edit"

      expect(rendered).to have_content("Resend Invitation")
    end

    it "allows a supervisor to resend invitation to a volunteer" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(supervisor)

      assign :volunteer, volunteer
      assign :supervisors, []

      render template: "volunteers/edit"

      expect(rendered).to have_content("Resend Invitation")
    end
  end
end
