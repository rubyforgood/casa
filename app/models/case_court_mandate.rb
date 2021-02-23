class CaseCourtMandate < ApplicationRecord
  belongs_to :casa_case

  validates :mandate_text, presence: true
end

# == Schema Information
#
# Table name: case_court_mandates
#
#  id           :bigint           not null, primary key
#  mandate_text :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  casa_case_id :bigint           not null
#
# Indexes
#
#  index_case_court_mandates_on_casa_case_id  (casa_case_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#
