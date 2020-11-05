class PastCourtDate < ApplicationRecord
  belongs_to :casa_case
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
