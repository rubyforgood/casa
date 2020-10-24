class CourtDate < ApplicationRecord
  belongs_to :casa_case

  scope :passed, -> { where("date < ?", Time.now)}
end

# == Schema Information
#
# Table name: court_dates
#
#  id           :bigint           not null, primary key
#  date         :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  casa_case_id :bigint           not null
#
# Indexes
#
#  index_court_dates_on_casa_case_id  (casa_case_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#
