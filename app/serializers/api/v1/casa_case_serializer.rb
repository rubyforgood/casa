class Api::V1::CasaCaseSerializer < ActiveModel::Serializer
  type "casa_case"
  attributes :id, :case_number, :casa_org_id, :birthday, :court_report_status, :court_report_submit_date, :youth_date_in_care

  def youth_date_in_care
    object.date_in_care.strftime("%Y-%m-%d") if object.date_in_care.present?
  end

  def birthday
    object.birth_month_year_youth.strftime("%Y-%m-%d") if object.birth_month_year_youth.present?
  end

  def court_report_submit_date
    object.court_report_submitted_at.strftime("%Y-%m-%d") if object.court_report_submitted_at.present?
  end
end
