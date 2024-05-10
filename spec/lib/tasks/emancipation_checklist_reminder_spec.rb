require "rails_helper"
require "rake"
Rake.application.rake_require "tasks/emancipation_checklist_reminder"

RSpec.describe "lib/tasks/emancipation_checklist_reminder.rake", ci_only: true do
  let(:rake_task) { Rake::Task["emancipation_checklist_reminder"].invoke }

  before do
    Rake::Task.clear
    Casa::Application.load_tasks

    travel_to Date.new(2022, 10, 1)
  end

  after do
    travel_back
  end

  context "volunteer with transition age youth case" do
    let!(:casa_case) { create(:casa_case, :with_one_case_assignment) }

    it "should send notification" do
      expect { rake_task }.to change { casa_case.case_assignments.first.volunteer.notifications.count }.by(1)
    end
  end

  context "volunteer with multiple transition age youth cases" do
    let!(:volunteer) { create(:volunteer, :with_casa_cases) }

    it "sends notification for each case" do
      expect { rake_task }.to change { volunteer.notifications.count }.by(CasaCase.count)
    end
  end

  context "volunteer without transition age youth case" do
    let!(:casa_case) { create(:casa_case, :with_one_case_assignment, birth_month_year_youth: 13.years.ago) }

    it "should not send notification" do
      expect { rake_task }.not_to change { casa_case.case_assignments.first.volunteer.notifications.count }
    end
  end

  context "when the case assignment is inactive" do
    let!(:case_assignment) { create(:case_assignment, :inactive) }

    it "should not send notification" do
      expect { rake_task }.not_to change { case_assignment.volunteer.notifications.count }
    end
  end

  context "when there are no case assignments" do
    it "does not raise error" do
      expect { rake_task }.not_to raise_error
    end
  end
end
