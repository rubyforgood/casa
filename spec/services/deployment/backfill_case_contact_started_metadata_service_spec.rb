require "rails_helper"

RSpec.describe Deployment::BackfillCaseContactStartedMetadataService do
  let(:past) { Date.new(2020, 1, 1).in_time_zone }
  let(:parsed_past) { past.as_json }

  let(:present) { Date.new(2024, 1, 1).in_time_zone }
  let(:parsed_present) { present.as_json }

  before { travel_to present }
  after { travel_back }

  context "when a case contact has status metadata" do
    let(:case_contact) { create(:case_contact) }

    context "when a case contact has status started metadata" do
      let!(:case_contact) { create(:case_contact, :started, created_at: past) }

      it "does not change metadata" do
        described_class.new.backfill_metadata

        expect(case_contact.reload.metadata.dig("status", "started")).to eq(parsed_past)
      end
    end

    context "when a case contact has other status metadata" do
      let!(:case_contact) {
        create(:case_contact, created_at: past, metadata:
        {"status" => {"details" => parsed_past}})
      }

      it "does not change status details" do
        described_class.new.backfill_metadata

        expect(case_contact.reload.metadata.dig("status", "started")).to eq(parsed_past)
      end

      it "sets status started" do
        described_class.new.backfill_metadata

        expect(case_contact.reload.metadata.dig("status", "started")).to eq(parsed_past)
      end
    end
  end

  context "when a case contact has no metadata" do
    let!(:case_contact) { create(:case_contact, created_at: past, metadata: {}) }

    it "does not change metadata" do
      described_class.new.backfill_metadata

      expect(case_contact.reload.metadata.dig("status", "started")).to be_nil
    end
  end
end
