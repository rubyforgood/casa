require "rails_helper"

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

      it "does not send email" do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context "multi-organization time-zone boundaries" do
      let!(:kolkata_org) { create(:casa_org, time_zone: "Asia/Kolkata") }
      let!(:ny_org) { create(:casa_org, time_zone: "America/New_York") }
      let!(:honolulu_org) { create(:casa_org, time_zone: "Pacific/Honolulu") }

      let!(:kolkata_supervisor) { create(:supervisor, casa_org: kolkata_org, active: true) }
      let!(:ny_supervisor) { create(:supervisor, casa_org: ny_org, active: true) }
      let!(:honolulu_supervisor) { create(:supervisor, casa_org: honolulu_org, active: true) }

      context "when UTC is early Monday morning (Sunday afternoon/evening in US)" do
        # 2026-11-23 02:00:00 UTC:
        # Kolkata (+5:30): Monday 07:30 (Monday)
        # New York (-5:00): Sunday 21:00 (Sunday)
        # Honolulu (-10:00): Sunday 16:00 (Sunday)
        before do
          travel_to Time.utc(2026, 11, 23, 2, 0, 0)
        end

        it "sends only to supervisors whose organization is locally on Monday" do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
          delivered_recipient = ActionMailer::Base.deliveries.last.to.first
          expect(delivered_recipient).to eq(kolkata_supervisor.email)
        end
      end

      context "when Monday arrives across all organizations" do
        # 2026-11-23 16:00:00 UTC:
        # Kolkata (+5:30): Monday 21:30
        # New York (-5:00): Monday 11:00
        # Honolulu (-10:00): Monday 06:00
        before do
          travel_to Time.utc(2026, 11, 23, 16, 0, 0)
        end

        it "sends to all supervisors active in each organization" do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(3)
        end

        it "does not send duplicate digests when executed again in the same week" do
          described_class.new.send!
          expect {
            described_class.new.send!
          }.not_to change { ActionMailer::Base.deliveries.count }
        end
      end

      context "early local Monday in positive UTC offset timezones (Sunday in UTC)" do
        let!(:tokyo_org) { create(:casa_org, time_zone: "Asia/Tokyo") }
        let!(:tokyo_supervisor) { create(:supervisor, casa_org: tokyo_org, active: true) }

        # Monday 01:00 AM JST is Sunday 16:00 UTC
        it "deduplicates correctly across the UTC date boundary" do
          travel_to Time.utc(2026, 1, 11, 16, 0, 0) do
            expect { described_class.new(tokyo_org).send! }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end

          # Later on Monday: 11:00 AM JST (02:00 UTC on Monday)
          travel_to Time.utc(2026, 1, 12, 2, 0, 0) do
            expect { described_class.new(tokyo_org).send! }.not_to change { ActionMailer::Base.deliveries.count }
          end
        end
      end
    end

    context "when initialized with a specific organization" do
      let!(:org1) { create(:casa_org, time_zone: "America/New_York") }
      let!(:org2) { create(:casa_org, time_zone: "America/New_York") }
      let!(:sup1) { create(:supervisor, casa_org: org1, active: true) }
      let!(:sup2) { create(:supervisor, casa_org: org2, active: true) }

      before do
        travel_to Time.utc(2026, 11, 23, 15, 0, 0) # Monday
      end

      it "only processes supervisors in the specified organization" do
        expect {
          described_class.new(org1).send!
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq([sup1.email])
      end
    end

    context "error resilience" do
      let!(:failing_org) { create(:casa_org, time_zone: "America/New_York") }
      let!(:healthy_org) { create(:casa_org, time_zone: "America/New_York") }
      let!(:failing_sup) { create(:supervisor, casa_org: failing_org, active: true) }
      let!(:healthy_sup) { create(:supervisor, casa_org: healthy_org, active: true) }

      before do
        travel_to Time.utc(2026, 11, 23, 15, 0, 0) # Monday
        allow(SupervisorMailer).to receive(:weekly_digest).with(failing_sup).and_raise("SMTP connection timeout")
        allow(SupervisorMailer).to receive(:weekly_digest).with(healthy_sup).and_call_original
      end

      it "logs the error and continues processing other organizations" do
        expect(Rails.logger).to receive(:error).with(/Failed sending supervisor weekly digest for CasaOrg #{failing_org.id}/)
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq([healthy_sup.email])
      end
    end
  end
end
