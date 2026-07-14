require "rails_helper"

RSpec.describe SupervisorDashboard do
  let(:organization) { create(:casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }

  def assign(volunteer)
    create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)
  end

  def active_case_for(volunteer)
    casa_case = create(:casa_case, casa_org: organization, active: true)
    create(:case_assignment, volunteer: volunteer, casa_case: casa_case, active: true)
    casa_case
  end

  describe "#volunteers" do
    it "returns the supervisor's actively-assigned volunteers" do
      assigned = create(:volunteer, casa_org: organization)
      assign(assigned)
      create(:volunteer, casa_org: organization) # assigned to no supervisor

      expect(described_class.new(supervisor).volunteers).to contain_exactly(assigned)
    end

    it "excludes volunteers whose supervisor assignment is inactive" do
      volunteer = create(:volunteer, casa_org: organization)
      create(:supervisor_volunteer, :inactive, supervisor: supervisor, volunteer: volunteer)

      expect(described_class.new(supervisor).volunteers).to be_empty
    end
  end

  describe "#rows" do
    it "marks a volunteer with no active cases as :no_cases" do
      assign(create(:volunteer, casa_org: organization))

      row = described_class.new(supervisor).rows.first
      expect(row.status).to eq(:no_cases)
      expect(row).to be_no_cases
      expect(row.cases_count).to eq(0)
    end

    it "marks a volunteer who has recently contacted all their cases as :on_track" do
      volunteer = create(:volunteer, casa_org: organization)
      assign(volunteer)
      casa_case = active_case_for(volunteer)
      create(:case_contact, creator: volunteer, casa_case: casa_case,
        contact_made: true, occurred_at: Time.zone.today, duration_minutes: 60)

      row = described_class.new(supervisor).rows.first
      expect(row.status).to eq(:on_track)
      expect(row).not_to be_needs_followup
      expect(row.cases_count).to eq(1)
      expect(row.last_contact_on.to_date).to eq(Time.zone.today)
      expect(row.minutes_recent).to eq(60)
    end

    it "marks a volunteer with an un-contacted case as :follow_up" do
      volunteer = create(:volunteer, casa_org: organization)
      assign(volunteer)
      active_case_for(volunteer) # no contact logged

      row = described_class.new(supervisor).rows.first
      expect(row.status).to eq(:follow_up)
      expect(row).to be_needs_followup
    end
  end

  describe "#needs_attention" do
    it "returns only the rows that need follow-up" do
      follow_up = create(:volunteer, casa_org: organization)
      assign(follow_up)
      active_case_for(follow_up)

      on_track = create(:volunteer, casa_org: organization)
      assign(on_track)
      contacted = active_case_for(on_track)
      create(:case_contact, creator: on_track, casa_case: contacted, contact_made: true, occurred_at: Time.zone.today)

      needs = described_class.new(supervisor).needs_attention
      expect(needs.map(&:volunteer)).to contain_exactly(follow_up)
    end
  end

  describe "#stats" do
    it "summarizes roster counts and recent hours" do
      on_track = create(:volunteer, casa_org: organization)
      assign(on_track)
      contacted = active_case_for(on_track)
      create(:case_contact, creator: on_track, casa_case: contacted,
        contact_made: true, occurred_at: Time.zone.today, duration_minutes: 90)

      follow_up = create(:volunteer, casa_org: organization)
      assign(follow_up)
      active_case_for(follow_up)

      assign(create(:volunteer, casa_org: organization)) # no cases

      stats = described_class.new(supervisor).stats
      expect(stats[:active]).to eq(3)
      expect(stats[:needs_followup]).to eq(1)
      expect(stats[:no_cases]).to eq(1)
      expect(stats[:hours_label]).to eq("1.5h")
    end

    it "reports 0h when there are no recent contact minutes" do
      assign(create(:volunteer, casa_org: organization))
      expect(described_class.new(supervisor).stats[:hours_label]).to eq("0h")
    end
  end

  describe SupervisorDashboard::Row do
    def build_row(**attrs)
      defaults = {
        volunteer: build_stubbed(:volunteer), cases_count: 1, status: :on_track,
        last_contact_on: nil, contacts_recent: 0, minutes_recent: 0
      }
      described_class.new(**defaults.merge(attrs))
    end

    it "labels the last contact relative to today" do
      expect(build_row(last_contact_on: nil).last_contact_label).to eq("No contact logged")
      expect(build_row(last_contact_on: Time.zone.today).last_contact_label).to eq("Today")
      expect(build_row(last_contact_on: 1.day.ago).last_contact_label).to eq("Yesterday")
      expect(build_row(last_contact_on: 5.days.ago).last_contact_label).to eq("5 days ago")
    end

    it "formats recent hours, showing an em dash for zero" do
      expect(build_row(minutes_recent: 0).hours_label).to eq("\u2014") # em dash
      expect(build_row(minutes_recent: 45).hours_label).to eq("45m")
      expect(build_row(minutes_recent: 60).hours_label).to eq("1h")
      expect(build_row(minutes_recent: 90).hours_label).to eq("1h 30m")
    end

    it "picks a deterministic avatar color from the palette" do
      expect(SupervisorDashboard::AVATAR_COLORS).to include(build_row.avatar_color)
    end
  end
end
