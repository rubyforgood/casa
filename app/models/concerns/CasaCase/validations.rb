require "active_support/concern"

module CasaCase::Validations
  extend ActiveSupport::Concern

  included do
    validates :birth_month_year_youth, presence: true
    validates :birth_month_year_youth, comparison: {
      less_than_or_equal_to: -> { Time.now.end_of_day },
      message: "is not valid: Youth's Birth Month & Year cannot be a future date.",
      allow_nil: true
    }
    validates :birth_month_year_youth, comparison: {
      greater_than_or_equal_to: "1989-01-01".to_date,
      message: "is not valid: Youth's Birth Month & Year cannot be prior to 1/1/1989.",
      allow_nil: true
    }

    validates :date_in_care, comparison: {
      less_than_or_equal_to: -> { Time.now.end_of_day },
      message: "is not valid: Youth's Date in Care cannot be a future date.",
      allow_nil: true
    }
    validates :date_in_care, comparison: {
      greater_than_or_equal_to: "1989-01-01".to_date,
      message: "is not valid: Youth's Date in Care cannot be prior to 1/1/1989.",
      allow_nil: true
    }

    validates :case_number, uniqueness: {scope: :casa_org_id, case_sensitive: false}, presence: true

    validates_presence_of :casa_case_contact_types,
      message: ": At least one contact type must be selected",
      if: :validate_contact_type

    # Validation to check timestamp and submission status of a case
    validates_with CourtReportValidator, fields: [:court_report_status, :court_report_submitted_at]
  end
end
