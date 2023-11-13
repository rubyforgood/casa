require "rails_helper"
require "rake"
Rake.application.rake_require "tasks/volunteer_birthday_reminder"

RSpec.describe "lib/tasks/volunteer_birthday_reminder.rake" do
  let(:rake_task) { Rake::Task["volunteer_birthday_reminder"].invoke }

  before do
    Rake::Task.clear
    Casa::Application.load_tasks

    travel_to Date.new(2022, 10, 15)
  end

  after do
    travel_back
  end

  context "there is a volunteer with a birthday next month" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: Date.new(1988, 11, 30))
    end

    it "creates a notification" do
      expect { rake_task }.to change { volunteer.supervisor.notifications.count }.by(1)
    end
  end

  context "there are many volunteers with birthdays next month" do
    volunteer_count = 10
    let!(:volunteer) do
      create_list(:volunteer, volunteer_count, :with_assigned_supervisor, date_of_birth: Date.new(1988, 11, 30))
    end

    it "creates many notifications" do
      expect { rake_task }.to change { Notification.count }.by(volunteer_count)
    end
  end

  context "there is an unsupervised volunteer with a birthday next month" do
    let!(:volunteer) do
      create(:volunteer, date_of_birth: Date.new(1988, 11, 30))
    end

    it "does not create a notification" do
      expect { rake_task }.to change { Notification.count }.by(0)
    end
  end

  context "there is a volunteer with no date_of_birth" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: nil)
    end

    it "does not create a notification" do
      expect { rake_task }.to change { volunteer.supervisor.notifications.count }.by(0)
    end
  end

  context "there is a volunteer with a birthday that is not next month" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: Date.new(1998, 7, 16))
    end

    it "does not create a notification" do
      expect { rake_task }.to change { volunteer.supervisor.notifications.count }.by(0)
    end
  end

  context "when today is the 15th" do
    before { travel_to(Date.new(2022, 10, 15)) }

    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: Date.new(1988, 11, 30))
    end

    it "runs the rake task" do
      expect { rake_task }.to change { volunteer.supervisor.notifications.count }.by(1)
    end
  end

  context "when today is not the 15th" do
    before { travel_to(Date.new(2022, 10, 1)) }

    it "skips the rake task" do
      expect { rake_task }.to change { Notification.count }.by(0)
    end
  end
end
