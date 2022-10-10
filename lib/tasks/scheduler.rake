desc "Clear court dates and report information when date has passed, run by heroku scheduler"
task clear_passed_dates: :environment do
  puts "Checking case due dates..."

  CasaCase.due_date_passed.each do |cc|
    cc.clear_court_dates
  end

  puts "done."
end
