require "rails_helper"

RSpec.describe "volunteers/edit", type: :view do
  it "allows an administrator to edit a volunteers email address" do
    administrator = build_stubbed :casa_admin
    enable_pundit(view, administrator)
    org = create :casa_org
    volunteer = create :volunteer, casa_org: org
    allow(view).to receive(:current_user).and_return(administrator)
    allow(view).to receive(:current_organization).and_return(administrator.casa_org)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to_not have_field("volunteer_email", readonly: true)
  end

  it "allows an administrator to edit a volunteers phone number" do
    administrator = build_stubbed :casa_admin
    enable_pundit(view, administrator)
    org = create :casa_org
    volunteer = create :volunteer, casa_org: org
    allow(view).to receive(:current_user).and_return(administrator)
    allow(view).to receive(:current_organization).and_return(administrator.casa_org)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to_not have_field("volunteer_email", readonly: true)
  end

  it "allows a supervisor to edit a volunteers email address" do
    supervisor = build_stubbed :supervisor
    enable_pundit(view, supervisor)
    org = create :casa_org
    volunteer = create :volunteer, casa_org: org
    allow(view).to receive(:current_user).and_return(supervisor)
    allow(view).to receive(:current_organization).and_return(supervisor.casa_org)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to_not have_field("volunteer_email", readonly: true)
  end

  it "allows a supervisor in the same org to edit a volunteers phone number" do
    org = create :casa_org
    supervisor = build_stubbed :supervisor, casa_org: org
    enable_pundit(view, supervisor)
    volunteer = create :volunteer, casa_org: org
    allow(view).to receive(:current_user).and_return(supervisor)
    allow(view).to receive(:current_organization).and_return(supervisor.casa_org)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to have_field("volunteer_phone_number")
  end

  it "does not allow a supervisor from a different org to edit a volunteers phone number" do
    different_supervisor = build_stubbed :supervisor
    enable_pundit(view, different_supervisor)
    org = create :casa_org
    volunteer = create :volunteer, casa_org: org
    allow(view).to receive(:current_user).and_return(different_supervisor)
    allow(view).to receive(:current_organization).and_return(different_supervisor.casa_org)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).not_to have_field("volunteer_phone_number")
  end

  it "shows invite and login info" do
    supervisor = build_stubbed :supervisor
    enable_pundit(view, supervisor)
    org = create :casa_org
    volunteer = create :volunteer, casa_org: org
    allow(view).to receive(:current_user).and_return(supervisor)
    allow(view).to receive(:current_organization).and_return(supervisor.casa_org)

    assign :volunteer, volunteer
    assign :supervisors, []

    render template: "volunteers/edit"

    expect(rendered).to have_text("Added to system ")
    expect(rendered).to have_text("Invitation email sent \n  never")
    expect(rendered).to have_text("Last logged in")
    expect(rendered).to have_text("Invitation accepted \n  never")
    expect(rendered).to have_text("Password reset last sent \n  never")
    expect(rendered).to have_text("Learning Hours This Year\n    0h 0min")
  end

  context "the user has requested to reset their password" do
    describe "shows resend invitation" do
      it "allows an administrator resend invitation to a volunteer" do
        volunteer = create :volunteer
        supervisor = build_stubbed :supervisor
        admin = build_stubbed :casa_admin

        enable_pundit(view, supervisor)
        allow(view).to receive(:current_user).and_return(admin)
        allow(view).to receive(:current_organization).and_return(admin.casa_org)

        assign :volunteer, volunteer
        assign :supervisors, []

        render template: "volunteers/edit"

        expect(rendered).to have_content("Resend Invitation")
      end

      it "allows a supervisor to resend invitation to a volunteer" do
        volunteer = create :volunteer
        supervisor = build_stubbed :supervisor

        enable_pundit(view, supervisor)
        allow(view).to receive(:current_user).and_return(supervisor)
        allow(view).to receive(:current_organization).and_return(supervisor.casa_org)

        assign :volunteer, volunteer
        assign :supervisors, []

        render template: "volunteers/edit"

        expect(rendered).to have_content("Resend Invitation")
      end
    end
  end
end
