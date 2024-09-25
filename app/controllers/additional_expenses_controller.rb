class AdditionalExpensesController < ApplicationController
  def create
    @additional_expense = AdditionalExpense.new(additional_expense_params)
    authorize @additional_expense

    respond_to do |format|
      if @additional_expense.save
        format.json { render json: @additional_expense.as_json, status: :created }
      else
        format.json { render json: @additional_expense.errors.as_json, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @additional_expense = AdditionalExpense.find(params[:id])
    authorize @additional_expense

    @additional_expense.destroy!

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def additional_expense_params
    params.require(:additional_expense)
      .permit(:case_contact_id, :other_expense_amount, :other_expenses_describe)
  end
end
