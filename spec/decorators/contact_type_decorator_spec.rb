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
      # Blank, not "never": a type with no contacts logged shows no subtext beside the option.
      expect(hash[:subtext]).to eq ""
    end

    context "with nil array" do
      it { expect(contact_type.decorate.hash_for_multi_select_with_cases(nil).class).to eq Hash }
    end
  end

  describe "last_logged_hint_with_cases" do
    let(:casa_case) { create(:casa_case, casa_org: casa_org) }

    it "is nil when the type has never been logged for the case" do
      expect(contact_type.decorate.last_logged_hint_with_cases([casa_case.id])).to be_nil
    end

    it "is a labeled recency phrase when the type has been logged" do
      case_contact = create(:case_contact, casa_case: casa_case, occurred_at: 3.days.ago)
      case_contact.contact_types << contact_type
      expect(contact_type.decorate.last_logged_hint_with_cases([casa_case.id])).to eq "Last logged 3 days ago"
    end
  end
end
