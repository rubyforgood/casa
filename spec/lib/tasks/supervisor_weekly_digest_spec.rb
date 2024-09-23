require "rails_helper"
require_relative "../../../lib/tasks/supervisor_weekly_digest"

RSpec.describe SupervisorWeeklyDigest do
  describe "#send!" do
    subject { described_class.new.send! }

    context "on monday" do
      context "with active and deactivated supervisor" do
        before do
          travel_to Time.zone.local(2021, 9, 27, 12, 0, 0) # monday noon
          create(:supervisor, active: true)
          create(:supervisor, active: false)
        end
        after { travel_back }

        it "only sends to active supervisor" do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(ActionMailer::Base.deliveries.last.subject).to eq("Weekly summary of volunteers' activities for the week of 2021-09-20")
        end
      end
    end

    context "not on monday" do
      before do
        travel_to Time.zone.local(2021, 9, 29, 12, 0, 0) # not monday
        create(:supervisor, active: true)
      end

      after { travel_back }

      it "does not send email" do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
