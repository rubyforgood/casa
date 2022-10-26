require "rails_helper"

RSpec.describe VolunteersEmailsExportCsvService do
  subject { described_class.new.perform }
  let!(:active_volunteer) { create(:volunteer, :with_casa_cases) }
  let!(:inactive_volunteer) { create(:volunteer, :inactive) }
  let(:active_volunteer_cases) { active_volunteer.casa_cases.active.pluck(:case_number).to_a.join(", ") }
  let(:active_volunteer_case_transition_aged) { active_volunteer.casa_cases.active.pluck(:transition_aged_youth).to_a.join(", ") }

  describe "#perform" do
    it "Exports correct data from volunteers" do
      results = subject.split("\n")
      expect(results.count).to eq(2)
      expect(results[0].split(",")).to eq(["Email", "Case Number", "Volunteer Name", "Case Transition Aged Status"])
      expect(results[1]).to eq("#{active_volunteer.email},\"#{active_volunteer_cases}\",#{active_volunteer.display_name},\"#{active_volunteer_case_transition_aged}\"")
    end

    it "includes active volunteers" do
      expect(subject).to match(/#{active_volunteer.email}/)
    end

    it "does not include inactive volunteers" do
      expect(subject).not_to match(/#{inactive_volunteer.email}/)
    end
  end
end
