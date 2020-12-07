class EmancipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_organization!

  # GET /casa_cases/:casa_case_id/emancipation
  def show
    @current_case = CasaCase.find(params[:casa_case_id])
    authorize @current_case
    @emancipation_form_data = EmancipationCategory.all
  end

  # POST /casa_cases/:casa_case_id/emancipation/save
  def save
    if !params.key?("casa_case_id")
      render json: {error: "Missing param casa_case_id"}
      return
    elsif !/\A\d+\z/.match(params[:casa_case_id])
      render json: {error: "Param casa_case_id must be a positive integer"}
      return
    end

    unless params.key?("option_action")
      render json: {error: "Missing param option_action"}
      return
    end

    if !params.key?("option_id")
      render json: {error: "Missing param option_id"}
      return
    elsif !/\A\d+\z/.match(params[:option_id])
      render json: {error: "Param option_id must be a positive integer"}
      return
    end

    begin
      current_case = CasaCase.find(params[:casa_case_id])
      authorize current_case, :update_emancipation_option?
    rescue ActiveRecord::RecordNotFound
      render json: {error: "Could not find case from id given by casa_case_id"}
      return
    end

    unless current_case.has_transitioned?
      render json: {error: "The current case is not marked as transitioning"}
      return
    end

    begin
      case params[:option_action]
      when "add"
        current_case.add_emancipation_option(params[:option_id])
        render json: "success".to_json
      when "delete"
        current_case.remove_emancipation_option(params[:option_id])
        render json: "success".to_json
      when "set"
        current_case.emancipation_options.delete(EmancipationOption.category_options(EmancipationOption.find(params[:option_id]).emancipation_category_id))
        current_case.add_emancipation_option(params[:option_id])
        render json: "success".to_json
      else
        render json: {error: "Param option_action did not contain a supported action"}
      end
    rescue ActiveRecord::RecordNotFound
      render json: {error: "Could not find option from id given by param option_id"}
    rescue ActiveRecord::RecordNotUnique
      render json: {error: "Option already added to case"}
    rescue => error
      render json: {error: error.message}
    end
  end

  # Render a json error for json endpoints
  def not_authorized(exception)
    if exception.backtrace[1].end_with?("save'")
      render json: {error: "Sorry, you are not authorized to perform this action. Did the session expire?"}
    else
      flash[:error] = "Sorry, you are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
  end
end
