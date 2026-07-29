desc "Delete case contact drafts nobody ever completed, scheduled daily in Heroku Scheduler"
task expire_case_contact_drafts: :environment do
  days = ENV.fetch("CASE_CONTACT_DRAFT_EXPIRY_DAYS", ExpireCaseContactDraftsService::DEFAULT_EXPIRY_DAYS)
  deleted = ExpireCaseContactDraftsService.new(days: days).perform

  puts "Deleted #{deleted} abandoned case contact #{"draft".pluralize(deleted)} (untouched for #{days}+ days)."
end
