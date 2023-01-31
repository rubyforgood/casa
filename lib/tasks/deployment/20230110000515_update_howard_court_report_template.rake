namespace :after_party do
  desc "Deployment task: update_howard_court_report_template"
  task update_howard_court_report_template: :environment do
    puts "Running deploy task 'update_howard_court_report_template'"

    casa_org = CasaOrg.find_by(name: "Howard County CASA")
    if casa_org
      casa_org.court_report_template.attach(io: File.new(Rails.root.join("app", "documents", "templates", "howard_county_report_template.docx")), filename: "howard_county_report_template.docx")
    else
      Bugsnag.notify("No Howard County CASA found for rake task update_howard_court_report_template")
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
