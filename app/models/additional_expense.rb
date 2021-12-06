class AdditionalExpense < ApplicationRecord

  belongs to :case_contact


end

# == Schema Information
#
# Table name: additional_expenses
#
#  id                      :bigint           not null, primary key
#  other-expenses-describe :string
#  other_expense_amount    :decimal(, )
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
