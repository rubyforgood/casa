class CaseCourtOrdersController < ApplicationController
  before_action :set_case_court_order, only: %i[destroy]
  before_action :require_organization!
  after_action :verify_authorized

  def destroy
    authorize @case_court_order
    @case_court_order.destroy
  end

  private

  def set_case_court_order
    @case_court_order = CaseCourtOrder.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
