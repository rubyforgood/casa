desc "Send an SMS to volunteers reminding them to connect with the contact types they have not connected with in the past 60 or more days"
task send_case_contact_types_reminder: :environment do
  CaseContactTypesReminder.new.send!
end
