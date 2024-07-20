require "rails_helper"

RSpec.describe CaseContactMetadataCallback do
  let(:past) { Date.new(2020, 1, 1).in_time_zone }
  let(:parsed_past) { past.as_json }

  let(:present) { Date.new(2024, 1, 1).in_time_zone }
  let(:parsed_present) { present.as_json }

  before { travel_to present }
  after { travel_back }

  # NOTE: as you might notice these tests are omitting quite a few cases
  # ex: notes => details, expenses => notes. I don't think it is worth dealing
  # with metadata surrounding cases that are not processed in the correct order.
  # A user would not be able to replicate this behavior.
  #
  describe "after_commit" do
    it "sets started metadata when case contact is created" do
      cc = create(:case_contact)

      expect(cc.metadata.dig("status", "active")).to eq(parsed_present)
    end

    context "case contact is in started status" do
      let(:case_contact) { create(:case_contact, status: "started", created_at: past) }

      context "updates to started status" do
        before { case_contact.update(status: "started") }

        it "does not update the metadata" do
          expect(case_contact.metadata.dig("status", "started")).to eq(parsed_past)
        end
      end

      context "updates to details status" do
        before { case_contact.update(status: "details") }

        it { expect(case_contact.metadata.dig("status", "details")).to eq(parsed_present) }
      end

      context "updates to notes status" do
        before { case_contact.update(status: "notes") }

        it { expect(case_contact.metadata.dig("status", "notes")).to eq(parsed_present) }
      end

      context "updates to expenses status" do
        before { case_contact.update(status: "expenses") }

        it { expect(case_contact.metadata.dig("status", "expenses")).to eq(parsed_present) }
      end

      context "updates to active status" do
        before { case_contact.update(status: "active") }

        it { expect(case_contact.metadata.dig("status", "active")).to eq(parsed_present) }
      end
    end

    context "case contact is in details status" do
      let(:case_contact) { create(:case_contact, status: "details", created_at: past) }

      context "updates to details status" do
        before { case_contact.update(status: "details") }

        it "does not update the metadata" do
          expect(case_contact.metadata.dig("status", "details")).to eq(parsed_past)
        end
      end

      context "updates to notes status" do
        before { case_contact.update(status: "notes") }

        it { expect(case_contact.metadata.dig("status", "notes")).to eq(parsed_present) }
      end

      context "updates to expenses status" do
        before { case_contact.update(status: "expenses") }

        it { expect(case_contact.metadata.dig("status", "expenses")).to eq(parsed_present) }
      end

      context "updates to active status" do
        before { case_contact.update(status: "active") }

        it { expect(case_contact.metadata.dig("status", "active")).to eq(parsed_present) }
      end
    end

    context "case contact is in notes status" do
      let(:case_contact) { create(:case_contact, status: "notes", created_at: past) }

      context "updates to notes status" do
        before { case_contact.update(status: "notes") }

        it { expect(case_contact.metadata.dig("status", "notes")).to eq(parsed_past) }
      end

      context "updates to expenses status" do
        before { case_contact.update(status: "expenses") }

        it { expect(case_contact.metadata.dig("status", "expenses")).to eq(parsed_present) }
      end

      context "updates to active status" do
        before { case_contact.update(status: "active") }

        it { expect(case_contact.metadata.dig("status", "active")).to eq(parsed_present) }
      end
    end

    context "case contact is in expenses status" do
      let!(:case_contact) { create(:case_contact, status: "expenses", created_at: past) }

      context "updates to expenses status" do
        before { case_contact.update(status: "expenses") }

        it "does not update the metadata" do
          expect(case_contact.metadata.dig("status", "expenses")).to eq(parsed_past)
        end
      end

      context "updates to active status" do
        before { case_contact.update(status: "active") }

        it { expect(case_contact.metadata.dig("status", "active")).to eq(parsed_present) }
      end
    end

    context "case contact is in active status" do
      let(:case_contact) { create(:case_contact, created_at: past) }

      context "updates to active status" do
        before { case_contact.update(status: "active") }

        it "does not update the metadata" do
          expect(case_contact.metadata.dig("status", "active")).to eq(parsed_past)
        end
      end
    end
  end
end
