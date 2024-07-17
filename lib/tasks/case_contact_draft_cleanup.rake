desc "delete draft case contacts marked for clean up, run by heroku scheduler."
task case_contact_draft_cleanup: :environment do
  DraftCaseContactCleanupService.call
end
