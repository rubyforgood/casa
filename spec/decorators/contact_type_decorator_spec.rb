require "rails_helper"

RSpec.describe ContactTypeDecorator do
  let(:casa_org) { create(:casa_org) }
  let(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
  let(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }

  describe "hash_for_multi_select_with_cases" do
    it "returns hash" do
      hash = contact_type.decorate.hash_for_multi_select_with_cases([])
      expect(hash[:value]).to eq contact_type.id
      expect(hash[:text]).to eq contact_type.name
      expect(hash[:group]).to eq contact_type_group.name
      expect(hash[:subtext]).to eq "never"
    end

    context "with nil array" do
      it { expect(contact_type.decorate.hash_for_multi_select_with_cases(nil).class).to eq Hash }
    end
  end

  describe "last_time_used_with_cases" do
    context "with empty array" do
      it { expect(contact_type.decorate.last_time_used_with_cases([])).to eq "never" }
    end

    context "with cases" do
      let(:casa_case) { create(:casa_case, casa_org: casa_org) }
      let(:casa_case_ids) { [casa_case.id] }

      context "with no case contacts" do
        it { expect(contact_type.decorate.last_time_used_with_cases([])).to eq "never" }
      end

      context "with case contacts" do
        let(:case_contact1) { create(:case_contact, casa_case: casa_case, occurred_at: 4.days.ago) }
        let(:case_contact2) { create(:case_contact, casa_case: casa_case, occurred_at: 3.days.ago) }

        it "is the most recent case contact" do
          case_contact1.contact_types << contact_type
          expect(contact_type.decorate.last_time_used_with_cases(casa_case_ids)).to eq "4 days ago"

          case_contact2.contact_types << contact_type
          expect(contact_type.decorate.last_time_used_with_cases(casa_case_ids)).to eq "3 days ago"
        end
      end
    end
  end
end
