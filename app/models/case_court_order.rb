class CaseCourtOrder < ApplicationRecord
  IMPLEMENTATION_STATUSES = {unimplemented: 1, partially_implemented: 2, implemented: 3}

  belongs_to :casa_case
  belongs_to :court_date, optional: true

  validates :text, presence: true

  enum implementation_status: IMPLEMENTATION_STATUSES

  def implementation_status_symbol
    case implementation_status
    when "implemented"
      "✅".freeze
    when "partially_implemented"
      "🕗".freeze
    else
      "❌".freeze
    end
  end
end

# == Schema Information
#
# Table name: case_court_orders
#
#  id                    :bigint           not null, primary key
#  implementation_status :integer
#  text                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  casa_case_id          :bigint           not null
#  court_date_id         :bigint
#
# Indexes
#
#  index_case_court_orders_on_casa_case_id   (casa_case_id)
#  index_case_court_orders_on_court_date_id  (court_date_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#
