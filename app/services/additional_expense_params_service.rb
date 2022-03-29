class AdditionalExpenseParamsService
  def initialize(params)
    @params = params
  end

  def calculate
    additional_expenses = @params.dig("case_contact", "additional_expenses_attributes")
    additional_expenses && 0.upto(10).map do |i|
      possible_key = i.to_s
      if additional_expenses&.key?(possible_key) && additional_expenses[i.to_s]["other_expense_amount"].present?
        additional_expenses[i.to_s]&.permit(:other_expense_amount, :other_expenses_describe, :id)
      end
    end.compact
  end
end
