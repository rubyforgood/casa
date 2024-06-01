class CaseCourtOrder < ApplicationRecord
  IMPLEMENTATION_STATUSES = {unimplemented: 1, partially_implemented: 2, implemented: 3}
  STANDARD_COURT_ORDERS = [
    "Create custom court order",
    "Individual therapy for the Respondent",
    "Family therapy",
    "Birth certificate for the Respondent\’s",
    "Educational or Vocational referrals",
    "Independent living skills classes or workshops",
    "Learners\’ permit for the Respondent, drivers\’ education and driving hours when needed",
    "Educational monitoring for the Respondent",
    "Tutor for the Respondent",
    "Individual therapy for the [parent]",
    "Substance abuse assessment for the [parent]",
    "Housing support for the [parent]",
    "Visitation assistance for the Respondent to see [family]",
    "No contact with (mother, father, other guardian)",
    "Supervised visits",
    "Supervised visits at DSS",
    "Virtual Visits",
    "Therapy (child, mother, father, other guardian)",
    "Psychiatric Evaluation and follow all recommendations (child, mother, father, other guardian)",
    "Substance Abuse Evaluation and follow all recommendations (child, mother, father, other guardian)",
    "Substance Abuse Treatment (child, mother, father, other guardian)",
    "Urinalysis (child, mother, father, other guardian)",
    "Parenting Classes (mother, father, other guardian)",
    "Domestic Violence Education/Group"
  ].freeze

  belongs_to :casa_case
  belongs_to :court_date, optional: true

  validates :text, presence: true

  enum implementation_status: IMPLEMENTATION_STATUSES

  def self.standard_court_order_options
    STANDARD_COURT_ORDERS.map{ |o| [o,o] }
  end
  
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
