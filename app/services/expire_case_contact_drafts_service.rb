# A case contact row is created the moment the form OPENS -- CaseContactsController#new inserts one so
# the wizard has somewhere to autosave -- so every abandoned "New case contact" click leaves a
# `started` draft behind, and nothing ever cleaned them up.
#
# Only `started` is expirable. `details` means the user attempted a real submit and hit validation, so
# it represents intent worth keeping; `active` is a finished contact. `updated_at` is the liveness
# signal because autosave touches it, so a draft someone is editing right now is never in range.
#
# HARD delete, not Paranoia's soft delete: CaseContact is `acts_as_paranoid`, and a soft-deleted draft
# keeps its row AND becomes *more* visible -- `grab_all` shows deleted records to CasaAdmins and the
# card prefixes them "[DELETE]" -- so soft-deleting would worsen the clutter it is meant to remove.
# Children have to go first: additional_expenses and contact_topic_answers hold FK constraints to
# case_contacts, so `really_destroy!` raises while their rows exist, and contact_topic_answers is
# itself paranoid, so a plain destroy leaves those rows behind.
class ExpireCaseContactDraftsService
  DEFAULT_EXPIRY_DAYS = 7

  def initialize(days: DEFAULT_EXPIRY_DAYS)
    @days = Integer(days)
    # Guards a misconfigured schedule from deleting drafts that are still being written.
    raise ArgumentError, "expiry must be at least 1 day, got #{@days}" if @days < 1
  end

  def perform
    deleted = 0
    expirable.find_each do |draft|
      delete(draft)
      deleted += 1
    end
    deleted
  end

  private

  attr_reader :days

  def expirable
    CaseContact.started.where(updated_at: ..days.days.ago)
  end

  def delete(draft)
    draft.followups.destroy_all
    draft.additional_expenses.destroy_all
    draft.case_contact_contact_types.destroy_all
    draft.contact_topic_answers.with_deleted.each(&:really_destroy!)
    draft.really_destroy!
  end
end
