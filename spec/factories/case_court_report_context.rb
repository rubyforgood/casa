FactoryBot.define do
  factory :case_court_report_context do
    skip_create # This model has no presence in the database

    transient do
      casa_case { nil }
      court_date { nil }
      volunteer { nil }
      case_court_orders { nil }
      path_to_report { Rails.root.join("tmp/test_report.docx").to_s }
      path_to_template { Rails.root.join("app/documents/templates/default_report_template.docx").to_s }
      start_date { nil }
      end_date { nil }
      time_zone { nil }
      casa_org do
        @overrides[:casa_case].try(:casa_org) ||
          @overrides[:volunteer].try(:casa_org) ||
          association(:casa_org)
      end
    end

    initialize_with {
      volunteer_for_context = volunteer.nil? ? create(:volunteer, casa_org:) : volunteer
      casa_case_for_context = casa_case.nil? ? create(:casa_case, casa_org:) : casa_case

      if volunteer_for_context && volunteer_for_context.casa_cases.where(id: casa_case_for_context.id).none?
        volunteer_for_context.casa_cases << casa_case_for_context
      end

      new(
        case_id: casa_case_for_context.id,
        volunteer_id: volunteer_for_context.try(:id),
        path_to_report: path_to_report,
        path_to_template: path_to_template,
        court_date: court_date,
        case_court_orders: case_court_orders,
        start_date: start_date,
        end_date: end_date,
        time_zone: time_zone
      )
    }
  end
end
