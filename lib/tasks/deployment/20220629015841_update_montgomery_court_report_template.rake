namespace :after_party do
  desc "Deployment task: update_montgomery_court_report_template"
  task update_montgomery_court_report_template: :environment do
    CasaOrg.where(name: "Voices for Children Montgomery").map do |casa_org|
      casa_org.court_report_template.attach(io: File.new(Rails.root.join("app", "documents", "templates", "montgomery_report_template_062022.docx")), filename: "montgomery_report_template_062022.docx")
    end
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
