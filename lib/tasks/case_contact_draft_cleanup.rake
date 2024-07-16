desc "delete draft case contacts marked for clean up, run by heroku scheduler."
task case_contact_draft_cleanup: :environment do
  CaseContact.drafts_for_removal.each do |draft|
    draft.destroy
  end
end
