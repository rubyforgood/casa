class FundRequestsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @fund_request = FundRequest.new
  end

  def create
    @fund_request = FundRequest.new(parsed_params)
    FundRequestMailer.send_request(nil, @fund_request).deliver
    redirect_to new_fund_request_path, notice: "Fund Request was sent"
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
