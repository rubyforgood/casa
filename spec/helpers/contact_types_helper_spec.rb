require "rails_helper"

RSpec.describe ContactTypesHelper, type: :helper do
  describe "#time_ago_of_last_contact_made_of" do
    subject { helper.time_ago_of_last_contact_made_of(contact_type_name, casa_case) }

    let(:casa_case) { build_stubbed(:casa_case) }
    let(:contact_type_name) { "School" }

    context "when contact never made" do
      before { allow(helper).to receive(:last_contact_made_of).and_return(nil) }

      it { is_expected.to eq("never") }
    end

    context "when contact was made" do
      before do
        contact = build_stubbed(:case_contact, casa_case:, created_at: 2.days.ago, occurred_at: 1.day.ago)
        allow(helper).to receive(:last_contact_made_of).and_return(contact)
      end

      it { is_expected.to eq("1 day ago") }
    end
  end

  describe "#last_contact_made_of" do
    subject { helper.last_contact_made_of(contact_type.name, casa_case) }

    let(:casa_case) { create(:casa_case) }
    let(:contact_type) { create(:contact_type) }

    let!(:contact1) do
      create(:case_contact, casa_case:, contact_types: [contact_type],
        created_at: 2.days.ago, occurred_at: 1.day.ago)
    end

    let!(:contact2) do
      create(:case_contact, casa_case:, contact_types: [contact_type],
        created_at: 1.day.ago, occurred_at: 2.days.ago)
    end

    it "returns the last contact made of the given type" do
      expect(subject).to eq(contact1)
    end

    context "when casa_case is nil" do
      subject { helper.last_contact_made_of(contact_type.name, nil) }

      it { is_expected.to be_nil }
    end
  end
end
