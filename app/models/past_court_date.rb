# frozen_string_literal: true

require "sablon"

class PastCourtDate < ApplicationRecord
  belongs_to :casa_case
  validate :date_must_be_past

  has_many :case_court_mandates
  belongs_to :hearing_type, optional: true
  belongs_to :judge, optional: true

  accepts_nested_attributes_for :case_court_mandates, reject_if: :all_blank

  scope :ordered_ascending, -> { order("date asc") }

  DOCX_TEMPLATE_PATH = Rails.root.join("app", "documents", "templates", "default_past_court_date_template.docx")

  def date_must_be_past
    if date.nil?
      errors.add(:date, "can't be blank")
    elsif date >= Date.today
      errors.add(:date, "must be in the past")
    end
  end

  # get reports associated with the case this belongs to before this court date but after the court date before this one
  def associated_reports
    prev = casa_case.past_court_dates.where("date < ?", date).order(:date).last
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
    case_court_mandates.any? || hearing_type || judge
  end

  def generate_report
    template = Sablon.template(File.expand_path(DOCX_TEMPLATE_PATH))

    template.render_to_string(context_hash)
  end

  def display_name
    "#{casa_case.case_number} - Past Court Date - #{I18n.l(date.to_date)}"
  end

  private

  def context_hash
    {
      court_date: date,
      case_number: casa_case.case_number,
      judge_name: judge&.name || "None",
      hearing_type_name: hearing_type&.name || "None",
      case_court_mandates: case_court_mandates_context_hash
    }
  end

  def case_court_mandates_context_hash
    case_court_mandates.map do |mandate|
      {
        text: mandate.mandate_text,
        implementation_status: mandate.implementation_status&.humanize
      }
    end
  end
end
# == Schema Information
#
# Table name: past_court_dates
#
#  id              :bigint           not null, primary key
#  date            :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  casa_case_id    :bigint           not null
#  hearing_type_id :bigint
#  judge_id        :bigint
#
# Indexes
#
#  index_past_court_dates_on_casa_case_id     (casa_case_id)
#  index_past_court_dates_on_hearing_type_id  (hearing_type_id)
#  index_past_court_dates_on_judge_id         (judge_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#
