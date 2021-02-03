class EmancipationsController < ApplicationController
  before_action :require_organization!
  after_action :verify_authorized

  # GET /casa_cases/:casa_case_id/emancipation
  def show
    @current_case = CasaCase.find(params[:casa_case_id])
    authorize @current_case
    @emancipation_form_data = EmancipationCategory.all
  end

  # POST /casa_cases/:casa_case_id/emancipation/save
  def save
    authorize CasaCase, :save_emancipation?
    if !params.key?("casa_case_id")
      render json: {error: "Missing param casa_case_id"}
      return
    elsif !/\A\d+\z/.match(params[:casa_case_id])
      render json: {error: "Param casa_case_id must be a positive integer"}
      return
    end

    unless params.key?("check_item_action")
      render json: {error: "Missing param check_item_action"}
      return
    end

    if !params.key?("check_item_id")
      render json: {error: "Missing param check_item_id"}
      return
    elsif !/\A\d+\z/.match(params[:check_item_id])
      render json: {error: "Param check_item_id must be a positive integer"}
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
      case params[:check_item_action]
        when "add_category"
          current_case.add_emancipation_category(params[:check_item_id])
          render json: "success".to_json
        when "add_option"
          current_case.add_emancipation_option(params[:check_item_id])
          render json: "success".to_json
        when "delete_category"
          current_case.remove_emancipation_category(params[:check_item_id])
          current_case.emancipation_options.delete(EmancipationOption.category_options(params[:check_item_id]))
          render json: "success".to_json
        when "delete_option"
          current_case.remove_emancipation_option(params[:check_item_id])
          render json: "success".to_json
        when "set_option"
          current_case.emancipation_options.delete(EmancipationOption.category_options(EmancipationOption.find(params[:check_item_id]).emancipation_category_id))
          current_case.add_emancipation_option(params[:check_item_id])
          render json: "success".to_json
        else
          render json: {error: "Param check_item_action did not contain a supported action"}
      end
    rescue ActiveRecord::RecordNotFound
      render json: {error: "Could not find option from id given by param check_item_id"}
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
      super()
    end
  end
end
