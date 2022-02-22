class AdditionalExpense < ApplicationRecord
  belongs_to :case_contact

  validates :other_expenses_describe, :presence => { :message => "Expense description cannot be blank."}
  # It is rejecting the expense line on both create and update, 
  # but there is not display of the message
  # And it creates the casa case
  # I think what is happening is the needs to a stop in the save process
  # And the controller has to explicitly redirect and show the error message

  # On create and update, its allow any values that have the description, rejecting those that don't regardless of order of those that don't (thats good!)


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
