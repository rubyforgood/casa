class AdditionalExpense < ApplicationRecord
  belongs_to :case_contact
  has_one :casa_case, through: :case_contact
  has_one :casa_org, through: :case_contact
  # case_contact.casa_org may be nil for draft contacts, use for fallback:
  has_one :contact_creator, through: :case_contact, source: :creator
  has_one :contact_creator_casa_org, through: :contact_creator, source: :casa_org

  validates :other_expenses_describe, presence: true, if: :describe_required?
  validates :other_expense_amount, presence: true, if: :amount_required?

  alias_attribute :amount, :other_expense_amount
  alias_attribute :describe, :other_expenses_describe

  # Amount and description are a pair: an amount needs a description, and a description needs an
  # amount -- so a started expense requires both (fill it in, or leave the whole row blank to drop
  # it). A brand-new blank row still saves, so "Add another expense" can create it, then fill.
  def describe_required?
    other_expense_amount&.positive?
  end

  def amount_required?
    other_expenses_describe.present?
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
