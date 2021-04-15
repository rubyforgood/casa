namespace :after_party do
  desc "Deployment task: set_custom_court_docs_for_orgs"
  task task_name: :environment do
    CasaOrg.where(name: "Prince George CASA").map do |casa_org|
      casa_org.court_report_template.attach(io: File.new(Rails.root.join("app", "documents", "templates", "prince_george_report_template.docx")), filename: "prince_george_report_template.docx")
    end

    CasaOrg.where(name: "Voices for Children Montgomery").map do |casa_org|
      casa_org.court_report_template.attach(io: File.new(Rails.root.join("app", "documents", "templates", "montgomery_report_template.docx")), filename: "montgomery_report_template.docx")
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
