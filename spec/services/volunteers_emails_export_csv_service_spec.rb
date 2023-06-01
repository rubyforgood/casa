require "rails_helper"

RSpec.describe VolunteersEmailsExportCsvService do
  describe "#call" do
    it "Exports correct data from volunteers" do
      casa_org = create(:casa_org)
      other_casa_org = create(:casa_org)

      active_volunteer = create(:volunteer, :with_casa_cases, casa_org: casa_org)
      inactive_volunteer = create(:volunteer, :inactive, casa_org: casa_org)
      other_org_volunteer = create(:volunteer, casa_org: other_casa_org)
      active_volunteer_cases = active_volunteer.casa_cases.active.map { |c| [c.case_number, c.in_transition_age?] }.to_h

      csv = described_class.new(casa_org).call

      results = csv.split("\n")
      expect(results.count).to eq(2)
      expect(results[0].split(",")).to eq(["Email", "Old Emails", "Case Number", "Volunteer Name", "Case Transition Aged Status"])
      expect(results[1]).to eq("#{active_volunteer.email},No Old Emails,\"#{active_volunteer_cases.keys.join(", ")}\",#{active_volunteer.display_name},\"#{active_volunteer_cases.values.join(", ")}\"")
      expect(csv).to match(/#{active_volunteer.email}/)
      expect(csv).not_to match(/#{inactive_volunteer.email}/)
      expect(csv).not_to match(/#{other_org_volunteer.email}/)
    end

    it "Exports correct data from volunteers, including old emails" do 
      casa_org_2 = create(:casa_org)
      volunteer_with_old_emails = create(:volunteer, old_emails: ["old_email@example.com"], casa_org: casa_org_2)
      csv = described_class.new(casa_org_2).call

      results = csv.split("\n")
      expect(results.count).to eq(2)
      expect(results[0].split(",")).to eq(["Email", "Old Emails", "Case Number", "Volunteer Name", "Case Transition Aged Status"])
      expect(results[1]).to eq("#{volunteer_with_old_emails.email},#{volunteer_with_old_emails.old_emails.join(", ")},\"\",#{volunteer_with_old_emails.display_name},\"\"")
    end 
  end
end
