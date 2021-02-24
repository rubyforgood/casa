require "rails_helper"

RSpec.describe SupervisorMailer, :type => :mailer do
  describe "notify" do
    let(:supervisor) { create :supervisor }

    let(:volunteer1) { create :volunteer, :with_casa_cases }
    let(:volunteer2) { create :volunteer, :with_casa_cases }

    let(:case1) { create :casa_case }
    let(:case2) { create :casa_case }

    let(:date1) { 3.days.ago }
    let(:date2) { 2.days.ago }

    let(:assignment1) { volunteer1.case_assignments_with_cases[0] }
    let(:assignment2) { volunteer1.case_assignments_with_cases[1] }
    let(:assignment3) { volunteer2.case_assignments_with_cases[0] }
    let(:assignment4) { volunteer2.case_assignments_with_cases[1] }

    let(:assignments) { [assignment1, assignment2, assignment3, assignment4] }
    
    let(:mail) { SupervisorMailer.weekly_digest(supervisor) }

    before do
      # munge the case assignment data so it looks like some of the activity occured earlier than it did
      # assigned before this week
      assignment1.updated_at = 20.days.ago
      assignment1.created_at = 20.days.ago
      # unassigned this week, but originally assigned earlier
      assignment2.updated_at = date1
      assignment2.created_at = 20.days.ago
      assignment2.is_active = false
      # assigned this week
      assignment3.updated_at = date1
      assignment3.created_at = date1
      # assigned this week, then unassigned later this week
      assignment4.updated_at = date2
      assignment4.created_at = date1
      assignment4.is_active = false

      assignments.each { |assignment| assignment.save! }

      # assign supervisor
      [volunteer1, volunteer2].each do |volunteer|
        volunteer.supervisor = supervisor
        volunteer.save!
      end
    end

    it "describes recent assignments" do
      inter = "</b> No contact attempts were logged for this week\. This volunteer was"
      # flatten whitespace and remove <br> tags from generated page
      # so that text matching is easier and more reliable
      mail_body_flat_ws = mail.body.encoded.gsub(/<br>/, ' ')
      mail_body_flat_ws = mail_body_flat_ws.gsub(/\s+/, ' ')
      # should not mention assignment
      expect(mail_body_flat_ws).not_to match /Summary for #{volunteer1.display_name} Case #{assignment1.casa_case.case_number}#{inter} assigned to this case/m
      # should mention removal but not assignment
      expect(mail_body_flat_ws).to match /Summary for #{volunteer1.display_name} Case #{assignment2.casa_case.case_number}#{inter} unassigned from this case on #{Regexp.escape(I18n.l(date1))}/m
      # should mention assignment
      expect(mail_body_flat_ws).to match /Summary for #{volunteer2.display_name} Case #{assignment3.casa_case.case_number}#{inter} assigned to this case on #{Regexp.escape(I18n.l(date1))}/m
      # should mention assignment and removal
      expect(mail_body_flat_ws).to match /Summary for #{volunteer2.display_name} Case #{assignment4.casa_case.case_number}#{inter} assigned to this case on #{Regexp.escape(I18n.l(date1))} and unassigned from\s+this case on #{Regexp.escape(I18n.l(date2))}/m
    end
  end
end