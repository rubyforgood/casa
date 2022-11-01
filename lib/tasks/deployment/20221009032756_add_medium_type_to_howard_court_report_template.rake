namespace :after_party do
  desc "Deployment task: add_medium_type_to_howard_court_report_template"
  task add_medium_type_to_howard_court_report_template: :environment do
    puts "Running deploy task 'add_medium_type_to_howard_court_report_template'"

    CasaOrg.where(name: "Howard County CASA").map do |casa_org|
      casa_org.court_report_template.attach(io: File.new(Rails.root.join("app", "documents", "templates", "howard_county_report_template.docx")), filename: "howard_county_report_template.docx")
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
