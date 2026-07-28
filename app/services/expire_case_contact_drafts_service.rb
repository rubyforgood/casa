# A case contact row is created the moment the form OPENS -- CaseContactsController#new inserts one so
# the wizard has somewhere to autosave -- so every abandoned "New case contact" click leaves a
# `started` draft behind, and nothing ever cleaned them up.
#
# Only `started` is expirable. `details` means the user attempted a real submit and hit validation, so
# it represents intent worth keeping; `active` is a finished contact. `updated_at` is the liveness
# signal because autosave touches it, so a draft someone is editing right now is never in range.
#
# Deletion goes through CaseContact#discard!, which hard-deletes and clears the children that hold FK
# constraints -- see there for why a soft delete would make the clutter worse.
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

  # CaseContact#discard! is the single place that knows how to take a draft apart -- the same path a
  # user's explicit "Discard draft" takes.
  def delete(draft)
    draft.discard!
  end
end
