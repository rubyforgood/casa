class FundRequestsController < ApplicationController
  def new
    @casa_case = CasaCase.find(params[:casa_case_id])
    @fund_request = FundRequest.new
  end

  def create
    @fund_request = FundRequest.new(parsed_params)
    FundRequestMailer.send_request(nil, @fund_request).deliver
    @casa_case = CasaCase.find(params[:casa_case_id])
    redirect_to casa_case_path(@casa_case), notice: "Fund Request was sent for case #{@casa_case.case_number}"
  end

  private

  def parsed_params
    params.permit(
      :submitter_email,
      :youth_name,
      :payment_amount,
      :deadline,
      :request_purpose,
      :payee_name,
      :requested_by_and_relationship,
      :other_funding_source_sought,
      :impact,
      :extra_information
    )
  end
end
