require "rails_helper"

RSpec.describe LearningHourPolicy::Scope do
  describe "#resolve" do
    it "returns all volunteers learning hours when user is a CasaAdmin" do
      casa_admin = create(:casa_admin)

      scope = described_class.new(casa_admin, LearningHour)

      expect(scope.resolve).to match_array(LearningHour.all_volunteers_learning_hours)
    end

    it "returns supervisor's volunteers learning hours when user is a Supervisor" do
      supervisor = create(:supervisor)
      create(:supervisor_volunteer, supervisor: supervisor)

      scope = described_class.new(supervisor, LearningHour)

      expect(scope.resolve).to match_array(LearningHour.supervisor_volunteers_learning_hours(supervisor.id))
    end

    it "returns volunteer's learning hours when user is a Volunteer" do
      volunteer = create(:volunteer)

      scope = described_class.new(volunteer, LearningHour)

      expect(scope.resolve).to match_array(LearningHour.where(user_id: volunteer.id))
    end
  end
end
