require "rails_helper"
require "rake"
Rake.application.rake_require "tasks/volunteer_birthday_reminder"

RSpec.describe "lib/tasks/volunteer_birthday_reminder.rake", ci_only: true do
  let(:rake_task) { Rake::Task["volunteer_birthday_reminder"].invoke }
  let(:now) { Date.new(2022, 10, 15) }
  let(:this_month) { now.month }
  let(:this_month_15th) { Date.new(now.year, now.month, 15) }
  let(:next_month) { Date.new(1988, this_month + 1, 1) }
  let(:not_next_month) { Date.new(1998, this_month - 1, 1) }

  before do
    Rake::Task.clear
    Casa::Application.load_tasks

    travel_to now
  end

  after do
    travel_back
  end

  context "there is a volunteer with a birthday next month" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: next_month)
    end

    it "creates a notification" do
      expect { rake_task }.to change { volunteer.supervisor.notifications.count }.by(1)
    end
  end

  context "there are many volunteers with birthdays next month" do
    volunteer_count = 10
    let!(:volunteer) do
      create_list(:volunteer, volunteer_count, :with_assigned_supervisor, date_of_birth: next_month)
    end

    it "creates many notifications" do
      expect { rake_task }.to change { Noticed::Notification.count }.by(volunteer_count)
    end
  end

  context "there is an unsupervised volunteer with a birthday next month" do
    let!(:volunteer) do
      create(:volunteer, date_of_birth: next_month)
    end

    it "does not create a notification" do
      expect { rake_task }.to change { Noticed::Notification.count }.by(0)
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
      create(:volunteer, :with_assigned_supervisor, date_of_birth: not_next_month)
    end

    it "does not create a notification" do
      expect { rake_task }.to change { volunteer.supervisor.notifications.count }.by(0)
    end
  end

  context "when today is the 15th" do
    before { travel_to(this_month_15th) }

    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: next_month)
    end

    it "runs the rake task" do
      expect { rake_task }.to change { volunteer.supervisor.notifications.count }.by(1)
    end
  end

  context "when today is not the 15th" do
    before { travel_to(this_month_15th + 2.days) }

    it "skips the rake task" do
      expect { rake_task }.to change { Noticed::Notification.count }.by(0)
    end
  end
end
