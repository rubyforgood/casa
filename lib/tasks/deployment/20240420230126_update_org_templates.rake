namespace :after_party do
  desc "Deployment task: Updates_production_casa_orgs_with_new_templates"
  task update_org_templates: :environment do
    puts "Running deploy task 'update_org_templates'"

    mapping = {
      "Howard County CASA" => "howard_county_report_template.docx",
      "Voices for Children Montgomery" => "montgomery_report_template.docx",
      "Prince George CASA" => "prince_george_report_template.docx"
    }

    mapping.each do |casa_org_name, template_file_name|
      casa_org = CasaOrg.find_by(name: casa_org_name)
      if casa_org
        casa_org.court_report_template.attach(
          io: File.new(Rails.root.join("app", "documents", "templates", template_file_name)),
          filename: template_file_name
        )
      else
        Bugsnag.notify("No #{casa_org_name} found for rake task update_org_templates")
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
