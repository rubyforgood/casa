class StandardCourtOrdersController < ApplicationController
  before_action :set_standard_court_order, only: %i[edit update destroy]
  after_action :verify_authorized

  def new
    authorize StandardCourtOrder
    standard_court_order = StandardCourtOrder.new(casa_org_id: current_user.casa_org_id)
    @standard_court_order = standard_court_order
  end

  def edit
    authorize @standard_court_order
  end

  def create
    authorize StandardCourtOrder
    @standard_court_order = StandardCourtOrder.new(standard_court_order_params)

    if @standard_court_order.save
      redirect_to edit_casa_org_path(current_organization), notice: "Standard court order was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @standard_court_order

    if @standard_court_order.update(standard_court_order_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Standard court order was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @standard_court_order

    @standard_court_order.destroy
    redirect_to edit_casa_org_path(current_organization), notice: "Standard court order was successfully deleted."
  end

  private

  def set_standard_court_order
    @standard_court_order = StandardCourtOrder.find(params[:id])
  end

  def standard_court_order_params
    params.require(:standard_court_order).permit(:casa_org_id, :value)
  end
end
