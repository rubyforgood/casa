require "rails_helper"

RSpec.describe "volunteers/edit", type: :view do
  let(:volunteer) {create :volunteer}

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

  context "The user has not accepted their invitation" do
    it "shows a string stating that the user has not recieved there invation yet" do
      expect("#{volunteer.display_name},
        has yet to accepted their invitation").to eq("#{volunteer.display_name},
        has yet to accepted their invitation")
    end
  end

  context "The user has accepted their invitation" do
    it "shows the datetime when the user recieved there invation" do
      expect(volunteer.invitation_accepted_at).to eq(volunteer.invitation_accepted_at)
    end
  end

  context " the user has not requested to reset their password" do
    it "shows no string at all" do
      expect(volunteer.reset_password_sent_at).to eq(nil)
    end
  end

  context " the user has requested to reset their password" do
    it "shows the datetime when the user recieved there invation" do
      expect(volunteer.reset_password_sent_at).to eq(volunteer.reset_password_sent_at)
    end
  end

end
