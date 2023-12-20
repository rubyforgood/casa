desc "Send an SMS to volunteers reminding them to make contact if two weeks have passed since they logged a case contact but contact was not made"
require_relative "case_contact_types_reminder"
task send_case_contact_types_reminder: :environment do
  every 1.days do
    CaseContactTypesReminder.new.send!
  end
end
