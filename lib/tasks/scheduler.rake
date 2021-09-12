desc "Clear court dates and report information when date has passed, run by heroku scheduler"
task clear_passed_dates: :environment do
  puts "Checking case due dates..."

  CasaCase.due_date_passed.each do |cc|
    PastCourtDate.create!(date: cc.court_date,
                          casa_case_id: cc.id,
                          case_court_mandates: cc.case_court_mandates,
                          hearing_type_id: cc.hearing_type_id,
                          judge_id: cc.judge_id)

    cc.clear_court_dates
  end

  puts "done."
end
