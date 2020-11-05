desc "Transition youth who are now 14, run by heroku scheduler"
task transition_youth: :environment do
  puts "Updating casa cases..."
  CasaCase.should_transition.update_all(transition_aged_youth: true)
  puts "done."
end

desc "Clear court dates and report information when date has passed, run by heroku scheduler"
task clear_passed_dates: :environment do
  puts "Checking case due dates..."
  CasaCase.due_date_passed.each do |cc|
    PastCourtDate.create!(date: cc.court_date, casa_case_id: cc.id)
    cc.clear_court_dates
  end
  puts "done."
end
