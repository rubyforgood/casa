require "rails_helper"
require "rake"

def empty_ar_classes
  ar_classes = [
    AllCasaAdmin,
    CasaAdmin,
    CasaCase,
    Judge,
    CasaOrg,
    CaseAssignment,
    CaseContact,
    ContactType,
    ContactTypeGroup,
    Supervisor,
    SupervisorVolunteer,
    User,
    LearningHour,
    HearingType,
    Volunteer,
    CaseCourtOrder
  ]
  ar_classes.select { |klass| klass.count == 0 }.map(&:name)
end

RSpec.describe "Seeds" do
  describe "test development DB" do
    before do
      Rails.application.load_tasks
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test"))
    end

    it "successfully populates all necessary tables" do
      ActiveRecord::Tasks::DatabaseTasks.load_seed
      expect(empty_ar_classes).to eq([])
    end
  end
end
