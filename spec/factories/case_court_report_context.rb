FactoryBot.define do
  factory :case_court_report_context do
    skip_create # This model has no presence in the database
    initialize_with {
      volunteer = create(:volunteer, :with_casa_cases)

      new(
        case_id: volunteer.casa_cases.first.id,
        volunteer_id: volunteer.id,
        path_to_template: Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s,
        path_to_report: Rails.root.join("tmp", "test_report.docx").to_s
      )
    }
  end
end
