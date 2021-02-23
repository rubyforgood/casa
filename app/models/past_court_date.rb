class PastCourtDate < ApplicationRecord
  belongs_to :casa_case

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
end
# == Schema Information
#
# Table name: past_court_dates
#
#  id           :bigint           not null, primary key
#  date         :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  casa_case_id :bigint           not null
#
# Indexes
#
#  index_past_court_dates_on_casa_case_id  (casa_case_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#
