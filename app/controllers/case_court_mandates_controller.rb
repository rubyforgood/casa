class CaseCourtMandatesController < ApplicationController
  before_action :set_case_court_mandate, only: %i[destroy]
  before_action :require_organization!
  after_action :verify_authorized

  def destroy
    authorize @case_court_mandate
    @case_court_mandate.destroy
  end

  private

  def set_case_court_mandate
    @case_court_mandate = CaseCourtMandate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
