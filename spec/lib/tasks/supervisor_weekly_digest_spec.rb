require "rails_helper"
require_relative "../../../lib/tasks/supervisor_weekly_digest"

RSpec.describe SupervisorWeeklyDigest do
  describe "#send!" do
    subject { described_class.new.send! }

    context "on monday" do
      before do
        travel_to Date.new(2021, 9, 27) # monday
      end

      context "with active and deactivated supervisor" do
        before do
          create(:supervisor, active: true)
          create(:supervisor, active: false)
        end

        it "only sends to active supervisor" do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(ActionMailer::Base.deliveries.last.subject).to eq("Weekly summary of volunteers' activities for the week of ")
        end
      end
    end

    context "not on monday" do
      before do
        travel_to Date.new(2021, 9, 28) # not monday
      end

      it "does not send email" do
        create(:supervisor, active: true)
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
