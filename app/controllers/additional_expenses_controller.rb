class AdditionalExpensesController < ApplicationController
  before_action :set_additional_expense, except: [:new, :create]


  def new
    @additional_expense = AdditionalExpenses.new
  end

  def create
    @additional_expense = AdditionalExpenses.new(additional_expense_params)

    if @additional_expense.save
      notice: "Additional Expense successfully created."
    else
      render :new
    end
  end

  def edit
    authorize @additional_expense
  end

  def update
    authorize @additional_expense
    if @additional_expense.update(additional_expense_params)
      notice: "Additional Expense was successfully updated."
    else
      render :edit
    end
  end

  private

  def set_additional_expense
    @additional_expense = AdditionalExpenses.find(params[:id])
  end

  def additional_expense_params
    params.require(:additional_expense).permit(:other_expense_amount, :other_expense_describe)
  end


end
