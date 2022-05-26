desc "Send an SMS to volunteers reminding them to connect with the contact types they have not connected with in the past 60 or more days"
require_relative "./case_contact_types_reminder"
task send_case_contact_types_reminder: :environment do
  every 1.days do # TODO: figure out how often we should run this
    CaseContactTypesReminder.new.send!
  end
end
