# frozen_string_literal: true

require "sablon"

class CourtDate < ApplicationRecord
  belongs_to :casa_case
  has_one :casa_org, through: :casa_case
  validates :date, presence: true
  validates :date, comparison: {
    less_than_or_equal_to: -> { 1.year.from_now },
    message: "is not valid. Court date must be within one year from today.",
    allow_nil: true
  }
  validates :date, comparison: {
    greater_than_or_equal_to: "1989-01-01".to_date,
    message: "is not valid. Court date cannot be prior to 1/1/1989.",
    allow_nil: true
  }

  has_many :case_court_orders
  belongs_to :hearing_type, optional: true
  belongs_to :judge, optional: true

  accepts_nested_attributes_for :case_court_orders, reject_if: :all_blank, allow_destroy: true

  before_save :set_court_report_due_date

  scope :ordered_ascending, -> { order("date asc") }

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

  def display_name
    "#{casa_case.case_number} - Court Date - #{I18n.l(date.to_date, format: :year_first)}"
  end

  private

  def set_court_report_due_date
    if date.present? && court_report_due_date.blank?
      self.court_report_due_date = date - 3.weeks
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
