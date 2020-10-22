require "rails_helper"
require "rake"

def empty_ar_classes
  ar_classes = [
    AllCasaAdmin,
    CasaAdmin,
    CasaCase,
    CasaOrg,
    CaseAssignment,
    CaseContact,
    ContactType,
    ContactTypeGroup,
    Supervisor,
    SupervisorVolunteer,
    User,
    Volunteer
  ]
  ar_classes.select { |klass| klass.count == 0 }.map(&:name)
end

RSpec.describe "Seeds" do
  ["development", "qa", "staging"].each do |environment|
    describe "for environment: #{environment}" do
      before do
        Rails.application.load_tasks
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment))
      end

      it "successfully populates all necessary tables" do
        ActiveRecord::Tasks::DatabaseTasks.load_seed
        expect(empty_ar_classes).to eq([])
      end
    end
  end
end
