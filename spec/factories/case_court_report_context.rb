FactoryBot.define do
  factory :case_court_report_context do
    skip_create # This model has no presence in the database

    transient do
      casa_case { nil }
      volunteer { nil }
      path_to_report { Rails.root.join("tmp", "test_report.docx").to_s }
      path_to_template { Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s }
    end

    initialize_with {
      if volunteer.nil? && casa_case.nil?
        volunteer = create(:volunteer, :with_casa_cases)
      elsif volunteer.nil?
        volunteer = create(:volunteer)
        volunteer.casa_cases << casa_case
      elsif casa_case.nil?
        volunteer.casa_cases << create(:casa_case)
      else
        unless volunteer.casa_cases.where(id: casa_case.id).exists?
          volunteer.casa_cases << casa_case
        end
      end

      new(
        case_id: volunteer.casa_cases.first.id,
        volunteer_id: volunteer.id,
        path_to_report: path_to_report,
        path_to_template: path_to_template
      )
    }
  end
end
