class AdditionalExpense < ApplicationRecord

  belongs to :case_contact
  
  attr_accessor :other_expense_amount,
  :other_expense_describe

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
#  case_contacts_id        :bigint           not null
#
# Indexes
#
#  index_additional_expenses_on_case_contacts_id  (case_contacts_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_contacts_id => case_contacts.id)
#
