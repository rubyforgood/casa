class DraftCaseContactCleanupService
  def self.call
    draft_expiration = 1.week.ago
    draft_expiration_without_case = 1.day.ago
    drafts_for_removal = CaseContact.where.not(status: "active").where("case_contacts.created_at < ?", draft_expiration)
      .or(CaseContact.where.not(status: "active").where(draft_case_ids: []).where("case_contacts.created_at < ?", draft_expiration_without_case))

    drafts_for_removal.each do |draft|
      draft.destroy
    end
  end
end
