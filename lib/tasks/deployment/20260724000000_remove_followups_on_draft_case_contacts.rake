namespace :after_party do
  desc "Deployment task: remove follow-up reminders left on draft (nil casa_case) case contacts"
  task remove_followups_on_draft_case_contacts: :environment do
    puts "Running deploy task 'remove_followups_on_draft_case_contacts'"

    # A reminder should only exist on a finalized case contact. Before reminders were gated to
    # active contacts, one could be set on a draft (casa_case still nil) -- which then raised a
    # UrlGenerationError on redirect. Remove any such orphaned follow-ups. The drafts themselves
    # are legitimate (unfinished wizard sessions) and are left untouched.
    orphaned = Followup.where(case_contact_id: CaseContact.where(casa_case_id: nil).select(:id))
    count = orphaned.count
    orphaned.delete_all
    puts "  removed #{count} orphaned follow-up(s) on draft case contacts"

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
