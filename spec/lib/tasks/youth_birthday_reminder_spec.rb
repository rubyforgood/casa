require "rails_helper"
require "rake"

RSpec.describe "youth_birthday_reminder rake task" do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  before(:each) do
    Rake::Task["youth_birthday_reminder"].reenable
    travel_to Date.new(2026, 1, 15)
  end

  subject(:run_task) { Rake::Task["youth_birthday_reminder"].invoke }

  # birthday_next_month matches on the birth MONTH; the youth's birth year must be
  # in the past (a future birth date is rejected by the model), so use a past year
  # with next calendar month.
  let!(:casa_case) { create(:casa_case, birth_month_year_youth: Date.new(2012, 2, 15)) }

  context "when today is the 15th of the month" do
    context "when a birthday-next-month case has no active assignment" do
      it "does not raise" do
        expect { run_task }.not_to raise_error
      end

      it "creates no notification" do
        expect { run_task }.not_to change(Noticed::Notification, :count)
      end
    end

    context "when a birthday-next-month case has an active assignment" do
      let!(:assignment) { create(:case_assignment, casa_case: casa_case, active: true) }

      it "notifies the assigned volunteer" do
        expect { run_task }.to change(Noticed::Notification, :count).by(1)
      end
    end

    context "when a birthday-next-month case has multiple active assignments" do
      let!(:assignments) { create_list(:case_assignment, 2, casa_case: casa_case, active: true) }

      it "notifies each active volunteer" do
        expect { run_task }.to change(Noticed::Notification, :count).by(2)
      end
    end

    context "when a case has both an active and an inactive assignment" do
      let!(:active_assignment) { create(:case_assignment, casa_case: casa_case, active: true) }
      let!(:inactive_assignment) { create(:case_assignment, casa_case: casa_case, active: false) }

      it "notifies only the active volunteer" do
        expect { run_task }.to change(Noticed::Notification, :count).by(1)
      end
    end

    context "when the only assignment is inactive" do
      let!(:assignment) { create(:case_assignment, casa_case: casa_case, active: false) }

      it "does not notify" do
        expect { run_task }.not_to change(Noticed::Notification, :count)
      end
    end
  end

  context "when today is not the 15th of the month" do
    before { travel_to Date.new(2026, 1, 14) }

    let!(:assignment) { create(:case_assignment, casa_case: casa_case, active: true) }

    it "does not notify" do
      expect { run_task }.not_to change(Noticed::Notification, :count)
    end

    context "when FORCE=true" do
      before do
        stub_const("ENV", ENV.to_h.merge("FORCE" => "true"))
      end

      it "notifies the assigned volunteer" do
        expect { run_task }.to change(Noticed::Notification, :count).by(1)
      end
    end
  end
end
