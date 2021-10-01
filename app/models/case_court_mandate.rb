class CaseCourtMandate < ApplicationRecord
  IMPLEMENTATION_STATUSES = {not_implemented: 1, partially_implemented: 2, implemented: 3}

  belongs_to :casa_case
  belongs_to :past_court_date, optional: true

  validates :mandate_text, presence: true

  enum implementation_status: IMPLEMENTATION_STATUSES

  def implementation_status_symbol
    case implementation_status
    when 'implemented'
      '✅'.freeze
    when 'partially_implemented'
      '🕗'.freeze
    else
      '❌'.freeze
    end
  end
end

# == Schema Information
#
# Table name: case_court_mandates
#
#  id                    :bigint           not null, primary key
#  implementation_status :integer
#  mandate_text          :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  casa_case_id          :bigint           not null
#  past_court_date_id    :bigint
#
# Indexes
#
#  index_case_court_mandates_on_casa_case_id        (casa_case_id)
#  index_case_court_mandates_on_past_court_date_id  (past_court_date_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#
