class AdditionalExpense < ApplicationRecord
  belongs_to :case_contact

  # validates :other_expense_amount, presence: true
  validates :other_expenses_describe, presence: {message: "Expense description cannot be blank."}
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
