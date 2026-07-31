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
  # Newest first, and ORDERED: this returned an unordered relation, so the row order was whatever
  # Postgres felt like -- fine for #latest_associated_report, which re-orders, but the spec asserted an
  # exact sequence and failed intermittently in a full-suite run. A list of reports has a natural
  # order; say so once here rather than leave every caller to guess.
  def associated_reports
    prev = casa_case.court_dates.where("date < ?", date).order(:date).last
    reports =
      if prev
        casa_case.court_reports.where("created_at > ?", prev.date).where("created_at < ?", date)
      else
        casa_case.court_reports.where("created_at < ?", date)
      end
    reports.order(created_at: :desc)
  end

  # `reorder`, not `order`: Rails APPENDS an order, so chaining `.order(:created_at).last` onto the
  # now-ordered relation produced `ORDER BY created_at DESC, created_at ASC` and handed back the OLDEST
  # report. Stating the order it wants makes this independent of however #associated_reports sorts.
  def latest_associated_report
    associated_reports.reorder(created_at: :desc).first
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
#  index_court_dates_on_casa_case_id  (casa_case_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#
