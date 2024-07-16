require "rails_helper"

RSpec.describe CaseContactUpdateService do
  let(:updater) { described_class.new(case_contact) }
  let(:case_contact) { create(:case_contact) }

  let!(:now) { Time.zone.now }
  let!(:one_day_ago) { 1.day.ago }
  let!(:two_days_ago) { 2.days.ago }

  before { travel_to one_day_ago }
  after { travel_back }

  describe "#update_attributes" do
    context "case is in details status" do
      let!(:case_contact) { create(:case_contact, status: "details", created_at: two_days_ago) }

      context "status is not updated" do
        before { updater.update_attrs({notes: "stuff"}) }

        it { expect(case_contact.metadata).to eq({}) }
        it { expect(updater.update_attrs({notes: "stuff"})).to be true }
      end

      it "does not update metadata if attrs are invalid" do
        result = updater.update_attrs({occurred_at: 50.years.ago})
        expect(case_contact.metadata).to eq({})
        expect(result).to be false
      end

      context "gets updated to details" do
        before { updater.update_attrs({status: "details"}) }

        it "updates details metadata to current date" do
          date = case_contact.metadata.dig("status", "details")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("details") }
      end

      context "gets updated to expenses" do
        before { updater.update_attrs({status: "expenses"}) }

        it "updates expenses metadata to current date" do
          date = case_contact.metadata.dig("status", "expenses")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("expenses") }
      end

      context "gets updated to active" do
        before { updater.update_attrs({status: "active"}) }

        it "updates active metadata to current date" do
          date = case_contact.metadata.dig("status", "active")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("active") }
      end
    end

    context "case is in expenses status" do
      let!(:case_contact) { create(:case_contact, status: "expenses", created_at: two_days_ago) }

      context "status is not updated" do
        before { updater.update_attrs({notes: "stuff"}) }

        it { expect(case_contact.metadata).to eq({}) }
        it { expect(updater.update_attrs({notes: "stuff"})).to be true }
      end

      it "does not update metadata if attrs are invalid" do
        result = updater.update_attrs({occurred_at: 50.years.ago})
        expect(case_contact.metadata).to eq({})
        expect(result).to be false
      end

      context "gets updated to details" do
        before { updater.update_attrs({status: "details"}) }

        it "updates details metadata to current date" do
          date = case_contact.metadata.dig("status", "details")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("details") }
      end

      context "gets updated to expenses" do
        before { updater.update_attrs({status: "expenses"}) }

        it "updates expenses metadata to current date" do
          date = case_contact.metadata.dig("status", "expenses")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("expenses") }
      end

      context "gets updated to active" do
        before { updater.update_attrs({status: "active"}) }

        it "updates active metadata to current date" do
          date = case_contact.metadata.dig("status", "active")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("active") }
      end
    end

    context "case is in active status" do
      let!(:case_contact) { create(:case_contact, status: "active", created_at: two_days_ago) }

      context "status is not updated" do
        before { updater.update_attrs({notes: "stuff"}) }

        it { expect(case_contact.metadata).to eq({}) }
        it { expect(updater.update_attrs({notes: "stuff"})).to be true }
      end

      it "does not update metadata if attrs are invalid" do
        result = updater.update_attrs({occurred_at: 50.years.ago})
        expect(case_contact.metadata).to eq({})
        expect(result).to be false
      end

      context "gets updated to details" do
        before { updater.update_attrs({status: "details"}) }

        it "updates details metadata to current date" do
          date = case_contact.metadata.dig("status", "details")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("details") }
      end

      context "gets updated to expenses" do
        before { updater.update_attrs({status: "expenses"}) }

        it "updates expenses metadata to current date" do
          date = case_contact.metadata.dig("status", "expenses")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("expenses") }
      end

      context "gets updated to active" do
        before { updater.update_attrs({status: "active"}) }

        it "updates active metadata to current date" do
          date = case_contact.metadata.dig("status", "active")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("active") }
      end
    end

    context "case is in started status" do
      let!(:case_contact) { create(:case_contact, status: "started", created_at: two_days_ago) }

      context "status is not updated" do
        before { updater.update_attrs({notes: "stuff"}) }

        it { expect(case_contact.metadata).to eq({}) }
        it { expect(updater.update_attrs({notes: "stuff"})).to be true }
      end

      it "does not update metadata if attrs are invalid" do
        result = updater.update_attrs({occurred_at: 50.years.ago})
        expect(case_contact.metadata).to eq({})
        expect(result).to be false
      end

      context "gets updated to details" do
        before { updater.update_attrs({status: "details"}) }

        it "updates details metadata to current date" do
          date = case_contact.metadata.dig("status", "details")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("details") }
      end

      context "gets updated to expenses" do
        before { updater.update_attrs({status: "expenses"}) }

        it "updates expenses metadata to current date" do
          date = case_contact.metadata.dig("status", "expenses")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("expenses") }
      end

      context "gets updated to active" do
        before { updater.update_attrs({status: "active"}) }

        it "updates active metadata to current date" do
          date = case_contact.metadata.dig("status", "active")
          expect(DateTime.parse(date)).to eq(Time.zone.now)
        end
        it { expect(case_contact.status).to eq("active") }
      end
    end
  end
end
