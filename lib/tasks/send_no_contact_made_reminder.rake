desc "Send an SMS to volunteers reminding them to make contact if two weeks have passed since they logged a case contact but contact was not made"
task send_no_contact_made_reminder: :environment do
  NoContactMadeReminder.new.send!
end
