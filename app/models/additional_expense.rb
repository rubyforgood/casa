class AdditionalExpense < ApplicationRecord
  belongs_to :case_contact
  has_one :casa_case, through: :case_contact
  has_one :casa_org, through: :case_contact
  # case_contact.casa_org may be nil for draft contacts, use for fallback:
  has_one :contact_creator, through: :case_contact, source: :creator
  has_one :contact_creator_casa_org, through: :contact_creator, source: :casa_org

  validates :other_expense_amount, presence: true, numericality: {greater_than: 0, allow_nil: true}, if: :require_complete?
  validates :other_expenses_describe, presence: true, if: :require_complete?

  alias_attribute :amount, :other_expense_amount
  alias_attribute :describe, :other_expenses_describe

  # A submitted expense must be complete: a positive amount AND a description. Enforced only once the
  # contact is being submitted (details/active). While it is still a "started" draft -- autosave, and
  # the blank row that "Add another expense" creates up front -- an incomplete row is allowed, so it
  # can be created then filled. On submit an incomplete or empty row blocks the form (fill it in or
  # remove it); we deliberately do NOT silently drop a blank row (the volunteer may have just
  # forgotten to finish it).
  def require_complete?
    case_contact&.active_or_details?
  end
end

# == Schema Information
#
# Table name: additional_expenses
#
#  id                      :bigint           not null, primary key
#  other_expense_amount    :decimal(, )
#  other_expenses_describe :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  case_contact_id         :bigint           not null
#
# Indexes
#
#  index_additional_expenses_on_case_contact_id  (case_contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_contact_id => case_contacts.id)
#
