FactoryBot.define do
  factory :case_court_report_context do
    skip_create # This model has no presence in the database

    transient do
      casa_case { nil }
      court_date { nil }
      volunteer { nil }
      path_to_report { Rails.root.join("tmp", "test_report.docx").to_s }
      path_to_template { Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s }
    end

    initialize_with {
      volunteer_for_context = volunteer.nil? ? create(:volunteer) : volunteer
      casa_case_for_context = casa_case.nil? ? create(:casa_case) : casa_case

      unless volunteer_for_context.casa_cases.where(id: casa_case_for_context.id).exists?
        volunteer_for_context.casa_cases << casa_case_for_context
      end

      new(
        case_id: casa_case_for_context.id,
        volunteer_id: volunteer_for_context.id,
        path_to_report: path_to_report,
        path_to_template: path_to_template,
        court_date: court_date
      )
    }
  end
end
