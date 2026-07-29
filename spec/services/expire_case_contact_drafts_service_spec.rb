require "rails_helper"

RSpec.describe ExpireCaseContactDraftsService do
  let(:casa_org) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: casa_org) }

  # `new` inserts the row before anything is entered, so an abandoned draft looks like this.
  def abandoned_draft(days_ago:, status: :started)
    draft = create(:case_contact, status, creator: volunteer, casa_case: nil, draft_case_ids: [casa_case.id])
    draft.update_columns(updated_at: days_ago.days.ago)
    draft
  end

  describe "#perform" do
    it "deletes a started draft nobody came back to" do
      draft = abandoned_draft(days_ago: 30)

      expect { described_class.new.perform }.to change(CaseContact, :count).by(-1)
      expect(CaseContact.with_deleted.where(id: draft.id)).to be_empty
    end

    it "hard deletes, so it cannot resurface as a [DELETE] row for admins" do
      draft = abandoned_draft(days_ago: 30)

      described_class.new.perform

      # A plain destroy would only set deleted_at; grab_all shows those to CasaAdmins.
      expect(CaseContact.with_deleted.exists?(draft.id)).to be false
    end

    it "keeps a draft that was touched inside the window" do
      abandoned_draft(days_ago: 2)

      expect { described_class.new.perform }.not_to change(CaseContact, :count)
    end

    it "keeps a details draft, which represents an attempted submit" do
      abandoned_draft(days_ago: 30, status: :details_status)

      expect { described_class.new.perform }.not_to change(CaseContact, :count)
    end

    it "never touches an active contact, however old" do
      contact = create(:case_contact, :active, creator: volunteer, casa_case: casa_case)
      contact.update_columns(updated_at: 400.days.ago)

      expect { described_class.new.perform }.not_to change(CaseContact, :count)
    end

    it "clears the children that hold FK constraints, instead of raising" do
      draft = abandoned_draft(days_ago: 30)
      contact_type = create(:contact_type, contact_type_group: create(:contact_type_group, casa_org: casa_org))
      draft.case_contact_contact_types.create!(contact_type: contact_type)
      create(:additional_expense, case_contact: draft)
      create(:contact_topic_answer, case_contact: draft, contact_topic: create(:contact_topic, casa_org: casa_org))

      expect { described_class.new.perform }.to change(CaseContact, :count).by(-1)
      expect(AdditionalExpense.where(case_contact_id: draft.id)).to be_empty
      expect(ContactTopicAnswer.with_deleted.where(case_contact_id: draft.id)).to be_empty
      expect(CaseContactContactType.where(case_contact_id: draft.id)).to be_empty
    end

    it "returns how many it deleted" do
      2.times { abandoned_draft(days_ago: 30) }
      abandoned_draft(days_ago: 1)

      expect(described_class.new.perform).to eq(2)
    end

    it "honours a custom window" do
      abandoned_draft(days_ago: 10)

      expect { described_class.new(days: 30).perform }.not_to change(CaseContact, :count)
      expect { described_class.new(days: 5).perform }.to change(CaseContact, :count).by(-1)
    end

    it "refuses a non-positive window, which would delete drafts being written" do
      expect { described_class.new(days: 0) }.to raise_error(ArgumentError, /at least 1 day/)
    end
  end
end
