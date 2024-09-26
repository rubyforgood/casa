require "rails_helper"

RSpec.describe VolunteerBirthdayReminderService do
  include ActiveJob::TestHelper

  let(:send_reminders) { described_class.new.send_reminders }
  let(:now) { Date.new(2022, 10, 15) }
  let(:this_month) { now.month }
  let(:this_month_15th) { Date.new(now.year, now.month, 15) }
  let(:next_month) { Date.new(1988, this_month + 1, 1) }
  let(:not_next_month) { Date.new(1998, this_month - 1, 1) }

  before do
    travel_to now
  end

  after do
    travel_back
    clear_enqueued_jobs
  end

  context "there is a volunteer with a birthday next month" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: next_month)
    end

    it "creates a notification" do
      expect { send_reminders }.to change { volunteer.supervisor.notifications.count }.by(1)
    end
  end

  context "there are multiple volunteers with birthdays next month" do
    let(:supervisor) { create(:supervisor) }
    let!(:volunteer) do
      create_list(:volunteer, 4, :with_assigned_supervisor, date_of_birth: next_month, supervisor: supervisor)
    end

    it "creates multiple notifications" do
      expect { send_reminders }.to change { Noticed::Notification.count }.by(4)
    end
  end

  context "there is an unsupervised volunteer with a birthday next month" do
    let!(:volunteer) do
      create(:volunteer, date_of_birth: next_month)
    end

    it "does not create a notification" do
      expect { send_reminders }.to change { Noticed::Notification.count }.by(0)
    end
  end

  context "there is a volunteer with no date_of_birth" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: nil)
    end

    it "does not create a notification" do
      expect { send_reminders }.to change { volunteer.supervisor.notifications.count }.by(0)
    end
  end

  context "there is a volunteer with a birthday that is not next month" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: not_next_month)
    end

    it "does not create a notification" do
      expect { send_reminders }.to change { volunteer.supervisor.notifications.count }.by(0)
    end
  end

  context "when today is the 15th" do
    before { travel_to(this_month_15th) }
    after { travel_back }

    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: next_month)
    end

    it "runs the rake task" do
      expect { send_reminders }.to change { volunteer.supervisor.notifications.count }.by(1)
    end
  end

  context "when today is not the 15th" do
    before { travel_to(this_month_15th + 2.days) }
    after { travel_back }

    it "skips the rake task" do
      expect { send_reminders }.to change { Noticed::Notification.count }.by(0)
    end
  end
end
