class Api::V1::CasaCasesController < Api::V1::BaseController
  before_action :set_casa_case, only: [:show, :update, :destroy]

  # GET /api/v1/casa_cases
  def index
    @casa_cases = current_user.casa_cases.all
    # puts current_user.inspect
    render json: @casa_cases, each_serializer: Api::V1::CasaCaseSerializer, status: :ok
  end
end
