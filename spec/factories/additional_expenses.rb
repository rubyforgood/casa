FactoryBot.define do
  factory :additional_expense do
    other_expense_amount { 20 }
    other_expenses_describe { "description of expense" }
    case_contact
  end
end
