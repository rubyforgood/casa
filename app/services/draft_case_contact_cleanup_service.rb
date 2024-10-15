class DraftCaseContactCleanupService
  ORPHANED_DRAFT_EXPIRATION_DELAY = 1.week.ago
  ORPHANED_DRAFT_EXPIRATION_DELAY_WITHOUT_CASE = 1.day.ago

  def self.call
    drafts_for_removal = CaseContact.where.not(status: "active").where("case_contacts.created_at < ?", ORPHANED_DRAFT_EXPIRATION_DELAY)
      .or(CaseContact.where.not(status: "active").where(draft_case_ids: []).where("case_contacts.created_at < ?", ORPHANED_DRAFT_EXPIRATION_DELAY_WITHOUT_CASE))

    drafts_for_removal.each do |draft|
      draft.destroy
    end
  end
end
