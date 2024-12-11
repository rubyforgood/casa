require "rails_helper"

RSpec.describe AdditionalExpenseParamsService do
  subject { described_class.new(params).calculate }

  context "single existing additional expense" do
    let(:params) { ActionController::Parameters.new(case_contact: {additional_expenses_attributes: {"0": {other_expense_amount: 10, other_expenses_describe: "hi", id: 1}}}) }

    it "calculates" do
      expect(subject.to_json).to eq("[{\"other_expense_amount\":10,\"other_expenses_describe\":\"hi\",\"id\":1}]")
    end
  end

  context "multiple new additional expense" do
    let(:params) {
      ActionController::Parameters.new(case_contact: {
        additional_expenses_attributes: {
          "0": {other_expense_amount: 10, other_expenses_describe: "new expense 0"},
          "1": {other_expense_amount: 20, other_expenses_describe: "new expense 1"}
        }
      })
    }

    it "calculates" do
      expect(subject.length).to eq(2)
      expect(subject[0]["other_expense_amount"]).to eq(10)
      expect(subject[0]["other_expenses_describe"]).to eq("new expense 0")
      expect(subject[1]["other_expense_amount"]).to eq(20)
      expect(subject[1]["other_expenses_describe"]).to eq("new expense 1")
    end
  end
end
