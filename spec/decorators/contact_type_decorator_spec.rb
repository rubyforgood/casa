require "rails_helper"

RSpec.describe ContactTypeDecorator do
  let(:contact_type) { create(:contact_type, name: "Supervisor") }

  describe "#time_difference_since_most_recent_contact" do
    let(:casa_case) { build(:casa_case) }

    context "when a case contact with the contact type was never made" do
      it "returns nil" do
        expect(contact_type.decorate.time_difference_since_most_recent_contact(casa_case)).to eq nil
      end
    end

    context "when contact with the contact type was made" do
      it "returns how long ago the contact was made" do
        case_contact = create(:case_contact, casa_case: casa_case, created_at: 1.day.ago)
        case_contact.contact_types << contact_type

        expect(contact_type.decorate.time_difference_since_most_recent_contact(casa_case)).to eq "1 day ago"
      end
    end
  end

  describe "#last_contact_made_of" do
    subject { helper.last_contact_made_of(contact_type.name, casa_case) }

    let(:casa_case) { create(:casa_case) }
    let(:contact_type) { create(:contact_type) }

    let!(:contact_1) { create(:case_contact, casa_case: casa_case, contact_types: [contact_type]) }

    let!(:contact_2) do
      create(:case_contact, casa_case: casa_case, contact_types: [contact_type],
             created_at: 1.day.ago)
    end

    it "returns the last contact made of the given type" do
      expect(subject).to eq(contact_1)
    end

    context "when casa_case is nil" do
      subject { helper.last_contact_made_of(contact_type.name, nil) }

      it { is_expected.to be_nil }
    end
  end
end
