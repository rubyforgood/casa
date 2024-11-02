require "rails_helper"
require_relative "../support/user_input_helpers"

RSpec.describe Volunteer do
  include UserInputHelpers

  let(:casa_org) { build :casa_org }

  describe "#send_court_report_reminder" do
    subject { described_class.send_court_report_reminder }

    let(:reminder_date) { Date.current + 7.days }
    let(:volunteer) { build :volunteer, casa_org: }
    let(:casa_case) { build :casa_case, casa_org: }
    let(:case_assignment) { create :case_assignment, volunteer:, casa_case: }
    let(:court_date) { create :court_date, casa_case:, court_report_due_date: reminder_date }

    before do
      case_assignment
      court_date

      stub_const("Volunteer::COURT_REPORT_SUBMISSION_REMINDER", 7.days)
      WebMockHelper.short_io_court_report_due_date_stub
      allow(VolunteerMailer).to receive(:court_report_reminder)
      allow(CourtReportDueSmsReminderService).to receive(:court_report_reminder)
    end

    context "when volunteer's case has report due on the reminder date" do
      it "calls VolunteerMailer#court_report_reminder(volunteer, reminder_date)" do
        subject
        expect(VolunteerMailer).to have_received(:court_report_reminder).with(volunteer, reminder_date)
      end

      it "calls CourtReportDueSmsReminderService#court_report_reminder(volunteer, reminder_date)" do
        subject
        expect(CourtReportDueSmsReminderService).to have_received(:court_report_reminder).with(volunteer, reminder_date)
      end
    end

    context "when volunteer is inactive" do
      before { volunteer.update!(active: false) }

      it "does not call volunteer mailer or sms service" do
        subject
        expect(VolunteerMailer).not_to have_received(:court_report_reminder)
        expect(CourtReportDueSmsReminderService).not_to have_received(:court_report_reminder)
      end
    end

    context "when case assignment is inactive" do
      before { case_assignment.update!(active: false) }

      it "does not call volunteer mailer or sms service" do
        subject
        expect(VolunteerMailer).not_to have_received(:court_report_reminder)
        expect(CourtReportDueSmsReminderService).not_to have_received(:court_report_reminder)
      end
    end

    context "when volunteer is not assigned to the case" do
      before { case_assignment.destroy! }

      it "does not call volunteer mailer or sms service" do
        subject
        expect(VolunteerMailer).not_to have_received(:court_report_reminder)
        expect(CourtReportDueSmsReminderService).not_to have_received(:court_report_reminder)
      end
    end

    context "when report is due after the reminder date" do
      before { court_date.update!(court_report_due_date: Date.current + 8.days) }

      it "does not call volunteer mailer or sms service" do
        subject
        expect(VolunteerMailer).not_to have_received(:court_report_reminder)
        expect(CourtReportDueSmsReminderService).not_to have_received(:court_report_reminder)
      end
    end

    context "when case is court report submitted" do
      before { casa_case.update!(court_report_submitted_at: Time.current, court_report_status: :submitted) }

      it "does not call volunteer mailer or sms service" do
        subject
        expect(VolunteerMailer).not_to have_received(:court_report_reminder)
        expect(CourtReportDueSmsReminderService).not_to have_received(:court_report_reminder)
      end
    end
  end

  describe "#activate" do
    let(:volunteer) { build(:volunteer, :inactive) }

    it "activates the volunteer" do
      expect(volunteer.active?).to be false
      volunteer.activate

      expect(volunteer.active?).to be true
    end
  end

  describe "#deactivate" do
    subject(:deactivate) { volunteer.deactivate }

    let(:volunteer) { create(:volunteer, casa_org:) }

    it "deactivates the volunteer" do
      expect(volunteer.active?).to be true
      deactivate
      expect(volunteer.active?).to be false
    end

    it "sets all of a volunteer's case assignments to inactive" do
      case_contacts = create_list(:case_assignment, 3, volunteer: volunteer)
      case_contacts.each { |contact| expect(contact.active?).to be true }

      deactivate

      case_contacts.each { |contact| expect(contact.reload.active?).to be false }
    end

    context "when volunteer has previously been assigned a supervisor" do
      before { create :supervisor_volunteer, volunteer: volunteer }

      it "deactivates the supervisor-volunteer relationship" do
        expect {
          deactivate
          volunteer.reload
        }.to change(volunteer, :supervisor_volunteer)
      end
    end

    context "when volunteer had no supervisor previously assigned" do
      it "does not attempt to update a supervisor-volunteer table" do
        expect {
          deactivate
          volunteer.reload
        }.not_to change(volunteer, :supervisor_volunteer)
      end
    end
  end

  describe "#display_name" do
    it "allows user to input dangerous values" do
      # this is a model, no input here???
      volunteer = build(:volunteer)
      UserInputHelpers::DANGEROUS_STRINGS.each do |dangerous_string|
        volunteer.update_attribute(:display_name, dangerous_string)
        volunteer.reload

        expect(volunteer.display_name).to eq dangerous_string
      end
    end
  end

  describe "#has_supervisor?" do
    context "when no supervisor_volunteer record" do
      let(:volunteer) { build_stubbed(:volunteer) }

      it "returns false" do
        expect(volunteer.has_supervisor?).to be false
      end
    end

    context "when active supervisor_volunteer record" do
      let(:sv) { create(:supervisor_volunteer, is_active: true) }
      let(:volunteer) { sv.volunteer }

      it "returns true" do
        expect(volunteer.reload.has_supervisor?).to be true
      end
    end

    context "when inactive supervisor_volunteer record" do
      let(:sv) { build_stubbed(:supervisor_volunteer, is_active: false) }
      let(:volunteer) { sv.volunteer }

      it "returns false" do
        expect(volunteer.has_supervisor?).to be false
      end
    end
  end

  describe "#made_contact_with_all_cases_in_days?" do
    let(:volunteer) { build(:volunteer, casa_org:) }
    let(:casa_case) { build(:casa_case, casa_org:) }

    context "when a volunteer is assigned to an active case" do
      let(:create_case_contact) do
        lambda { |occurred_at, contact_made|
          create(:case_contact, casa_case: casa_case, creator: volunteer, occurred_at: occurred_at, contact_made: contact_made)
        }
      end

      before do
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
      end

      context "when volunteer has made recent contact" do
        it "returns true" do
          create_case_contact.call(Date.current, true)
          expect(volunteer.made_contact_with_all_cases_in_days?).to be true
        end
      end

      context "when volunteer has made recent contact attempt but no contact made" do
        it "returns true" do
          create_case_contact.call(Date.current, false)
          expect(volunteer.made_contact_with_all_cases_in_days?).to be false
        end
      end

      context "when volunteer has not made recent contact" do
        it "returns false" do
          create_case_contact.call(Date.current - 60.days, true)
          expect(volunteer.made_contact_with_all_cases_in_days?).to be false
        end
      end

      context "when volunteer has not made recent contact in just one case" do
        it "returns false" do
          after_reminder_case = build(:casa_case, casa_org:)
          create(:case_assignment, casa_case: after_reminder_case, volunteer: volunteer)
          create(:case_contact, casa_case: after_reminder_case, creator: volunteer, occurred_at: Date.current - 60.days, contact_made: true)
          create_case_contact.call(Date.current, true)
          expect(volunteer.made_contact_with_all_cases_in_days?).to be false
        end
      end
    end

    context "when volunteer has no case assignments" do
      it "returns true" do
        expect(volunteer.made_contact_with_all_cases_in_days?).to be true
      end
    end

    context "when a volunteer has only an inactive case where contact was not made recently" do
      it "returns true" do
        inactive_case = build_stubbed(:casa_case, casa_org:, active: false)
        build_stubbed(:case_assignment, casa_case: inactive_case, volunteer: volunteer)
        build_stubbed(:case_contact, casa_case: inactive_case, creator: volunteer, occurred_at: Date.current - 60.days, contact_made: true)

        expect(volunteer.made_contact_with_all_cases_in_days?).to be true
      end
    end

    context "when a volunteer has only an unassigned case where contact was not made recently" do
      it "returns true" do
        build_stubbed(:case_assignment, casa_case: casa_case, volunteer: volunteer, active: false)
        build_stubbed(:case_contact, casa_case: casa_case, creator: volunteer, occurred_at: Date.current - 60.days, contact_made: true)

        expect(volunteer.made_contact_with_all_cases_in_days?).to be true
      end
    end
  end

  describe "#supervised_by?" do
    it "is supervised by the currently active supervisor" do
      supervisor = build_stubbed :supervisor
      volunteer = build_stubbed :volunteer, supervisor: supervisor

      expect(volunteer).to be_supervised_by(supervisor)
    end

    it "is not supervised by supervisors that have never supervised the volunteer before" do
      supervisor = build_stubbed :supervisor
      volunteer = build_stubbed :volunteer

      expect(volunteer).not_to be_supervised_by(supervisor)
    end

    it "is not supervised by supervisor that had the volunteer unassinged" do
      old_supervisor = create :supervisor
      new_supervisor = create :supervisor
      volunteer = create :volunteer, supervisor: old_supervisor

      volunteer.update! supervisor: new_supervisor

      expect(volunteer).not_to be_supervised_by(old_supervisor)
      expect(volunteer).to be_supervised_by(new_supervisor)
    end
  end

  describe "#role" do
    subject(:volunteer) { build_stubbed :volunteer }

    it { expect(volunteer.role).to eq "Volunteer" }
  end

  describe ".with_no_supervisor" do
    subject { described_class.with_no_supervisor(casa_org) }

    let(:casa_org) { create(:casa_org) }

    context "volunteers" do
      let!(:unassigned1) { create(:volunteer, display_name: "aaa", casa_org: casa_org) }
      let!(:unassigned2) { create(:volunteer, display_name: "bbb", casa_org: casa_org) }
      let!(:unassigned_inactive) { create(:volunteer, display_name: "unassigned inactive", casa_org: casa_org, active: false) }
      let!(:different_org) { build(:casa_org) }
      let!(:unassigned2_different_org) { build(:volunteer, display_name: "ccc", casa_org: different_org) }
      let!(:assigned1) { build(:volunteer, display_name: "ddd", casa_org: casa_org) }
      let!(:supervisor) { create(:supervisor, display_name: "supe", casa_org: casa_org) }
      let!(:assignment1) { create(:supervisor_volunteer, volunteer: assigned1, supervisor: supervisor) }
      let!(:assigned2_different_org) { assignment1.volunteer }
      let!(:unassigned_inactive_volunteer) { build(:volunteer, display_name: "eee", casa_org: casa_org, active: false) }
      let!(:previously_assigned) { create(:volunteer, display_name: "fff", casa_org: casa_org) }
      let!(:inactive_assignment) { build(:supervisor_volunteer, volunteer: previously_assigned, is_active: false, supervisor: supervisor) }

      it "returns unassigned volunteers" do
        expect(subject.map(&:display_name).sort).to eq ["aaa", "bbb", "fff"]
      end
    end
  end

  describe ".with_supervisor" do
    subject { described_class.with_supervisor }

    let!(:unassigned1) { create(:volunteer, display_name: "aaa", casa_org:) }
    let!(:unassigned2) { create(:volunteer, display_name: "bbb", casa_org:) }

    let!(:supervisor1) { create(:supervisor, display_name: "supe1", casa_org:) }
    let!(:assigned1) { create(:volunteer, display_name: "ccc", casa_org:) }
    let!(:assignment1) { create(:supervisor_volunteer, volunteer: assigned1, supervisor: supervisor1) }

    let!(:supervisor2) { create(:supervisor, display_name: "supe2", casa_org:) }
    let!(:assigned2) { create(:volunteer, display_name: "ddd", casa_org:) }
    let!(:assignment2) { create(:supervisor_volunteer, volunteer: assigned2, supervisor: supervisor2) }

    let!(:assigned3) { create(:volunteer, display_name: "eee", casa_org:) }
    let!(:assignment3) { create(:supervisor_volunteer, volunteer: assigned3, supervisor: supervisor2) }

    it { is_expected.to contain_exactly(assigned1, assigned2, assigned3) }
  end

  describe ".birthday_next_month" do
    subject { described_class.birthday_next_month }

    before do
      travel_to Date.new(2022, 10, 1)
    end

    context "there are volunteers whose birthdays are not next month" do
      let!(:volunteer1) { create(:volunteer, date_of_birth: Date.new(1990, 9, 1)) }
      let!(:volunteer2) { create(:volunteer, date_of_birth: Date.new(1998, 10, 15)) }
      let!(:volunteer3) { create(:volunteer, date_of_birth: Date.new(1920, 12, 1)) }

      it { is_expected.to be_empty }
    end

    context "there are volunteers whose birthdays are next month" do
      let!(:volunteer1) { create(:volunteer, date_of_birth: Date.new(2001, 11, 1)) }
      let!(:volunteer2) { create(:volunteer, date_of_birth: Date.new(1920, 11, 15)) }
      let!(:volunteer3) { create(:volunteer, date_of_birth: Date.new(1989, 11, 30)) }

      let!(:volunteer4) { create(:volunteer, date_of_birth: Date.new(2001, 6, 1)) }
      let!(:volunteer5) { create(:volunteer, date_of_birth: Date.new(1920, 1, 15)) }
      let!(:volunteer6) { create(:volunteer, date_of_birth: Date.new(1967, 2, 21)) }

      it { is_expected.to contain_exactly(volunteer1, volunteer2, volunteer3) }
    end
  end

  describe "#with_assigned_cases" do
    subject { described_class.with_assigned_cases }

    let!(:volunteers) { create_list(:volunteer, 3) }
    let!(:volunteer_with_cases) { create_list(:volunteer, 3, :with_casa_cases) }

    it "returns only volunteers assigned to active casa cases" do
      expect(subject).to match_array(volunteer_with_cases)
    end
  end

  describe "#with_no_assigned_cases" do
    subject { described_class.with_no_assigned_cases }

    let!(:volunteers) { create_list(:volunteer, 3) }
    let!(:volunteer_with_cases) { create_list(:volunteer, 3, :with_casa_cases) }

    it "returns only volunteers with no assigned active casa cases" do
      expect(subject).to match_array(volunteers)
    end
  end

  describe "#casa_cases" do
    let(:volunteer) { create :volunteer }
    let!(:ca1) { create :case_assignment, volunteer: volunteer, active: true }
    let!(:ca2) { create :case_assignment, volunteer: volunteer, active: false }
    let!(:ca3) { create :case_assignment, volunteer: create(:volunteer), active: true }
    let!(:ca4) { create :case_assignment, casa_case: create(:casa_case, active: false), active: true }
    let!(:ca5) { create :case_assignment, casa_case: create(:casa_case, active: false), active: false }

    it "returns only active and actively assigned casa cases" do
      expect(volunteer.casa_cases.count).to eq(1)
      expect(volunteer.casa_cases).to eq([ca1.casa_case])
    end
  end

  describe "invitation expiration" do
    let(:volunteer) { create :volunteer }
    let!(:mail) { volunteer.invite! }
    let(:expiration_date) { I18n.l(volunteer.invitation_due_at, format: :full, default: nil) }
    let(:one_year) { I18n.l(1.year.from_now, format: :full, default: nil) }

    it { expect(expiration_date).to eq one_year }

    it "expires invitation token after one year" do
      travel_to 1.year.from_now

      user = User.accept_invitation!(invitation_token: volunteer.invitation_token)
      expect(user.errors.full_messages).to include("Invitation token is invalid")
      travel_back
    end
  end

  describe "#learning_hours_spent_in_one_year" do
    let(:volunteer) { create :volunteer }
    let(:learning_hour_type) { create :learning_hour_type }
    let!(:learning_hours) do
      [
        create(:learning_hour, user: volunteer, duration_hours: 1, duration_minutes: 30, learning_hour_type: learning_hour_type),
        create(:learning_hour, user: volunteer, duration_hours: 3, duration_minutes: 45, learning_hour_type: learning_hour_type),
        create(:learning_hour, user: volunteer, duration_hours: 1, duration_minutes: 30, occurred_at: 2.year.ago, learning_hour_type: learning_hour_type)
      ]
    end

    it "returns the hours spent in one year" do
      expect(volunteer.learning_hours_spent_in_one_year).to eq("5h 15min")
    end
  end
end
