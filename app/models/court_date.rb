# frozen_string_literal: true

require "sablon"

class CourtDate < ApplicationRecord
  belongs_to :casa_case
  validates :date, presence: true

  has_many :case_court_orders
  belongs_to :hearing_type, optional: true
  belongs_to :judge, optional: true

  accepts_nested_attributes_for :case_court_orders, reject_if: :all_blank

  scope :ordered_ascending, -> { order("date asc") }

  DOCX_TEMPLATE_PATH = ::CasaOrg::CASA_DEFAULT_COURT_REPORT

  # get reports associated with the case this belongs to before this court date but after the court date before this one
  def associated_reports
    prev = casa_case.court_dates.where("date < ?", date).order(:date).last
    if prev
      casa_case.court_reports.where("created_at > ?", prev.date).where("created_at < ?", date)
    else
      casa_case.court_reports.where("created_at < ?", date)
    end
  end

  def latest_associated_report
    associated_reports.order(:created_at).last
  end

  def additional_info?
    case_court_orders.any? || hearing_type || judge
  end

  def generate_report(current_user, time_zone)
    args = {
      volunteer_id: current_user.volunteer? ? current_user.id : casa_case.assigned_volunteers.first&.id,
      case_id: casa_case.id,
      path_to_template: DOCX_TEMPLATE_PATH.to_path,
      time_zone: time_zone,
      court_date: date
    }
    context = CaseCourtReportContext.new(args).context
    court_report = CaseCourtReport.new(path_to_template: DOCX_TEMPLATE_PATH.to_path, context: context)
    return court_report.generate_to_string
  end

  def display_name
    "#{casa_case.case_number} - Court Date - #{I18n.l(date.to_date)}"
  end

  private

  def context_hash
    {
      court_date: date,
      case_number: casa_case.case_number,
      judge_name: judge&.name || "None",
      hearing_type_name: hearing_type&.name || "None",
      case_court_orders: case_court_orders_context_hash
    }
  end

  def case_court_orders_context_hash
    case_court_orders.map do |order|
      {
        text: order.text,
        implementation_status: order.implementation_status&.humanize
      }
    end
  end
end
# == Schema Information
#
# Table name: court_dates
#
#  id                    :bigint           not null, primary key
#  court_report_due_date :datetime
#  date                  :datetime         not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  casa_case_id          :bigint           not null
#  hearing_type_id       :bigint
#  judge_id              :bigint
#
# Indexes
#
#  index_court_dates_on_casa_case_id     (casa_case_id)
#  index_court_dates_on_hearing_type_id  (hearing_type_id)
#  index_court_dates_on_judge_id         (judge_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#
