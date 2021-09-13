require "rails_helper"

RSpec.describe VolunteerDecorator do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  describe "CC reminder text" do
    context "when user is admin" do
      it "includes both supervisor and admin in prompt" do
        sign_in admin

        expect(volunteer.decorate.cc_reminder_text).to include "Supervisor"
        expect(volunteer.decorate.cc_reminder_text).to include "Admin"
      end
    end

    context "when user is supervisor" do
      it "includes only supervisor in prompt" do
        sign_in supervisor

        expect(volunteer.decorate.cc_reminder_text).to include "Supervisor"
        expect(volunteer.decorate.cc_reminder_text).not_to include "Admin"
      end
    end
  end
end
