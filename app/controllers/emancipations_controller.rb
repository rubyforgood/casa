class EmancipationsController < ApplicationController
  before_action :authenticate_user!

  # GET /casa_cases/:casa_case_id/emancipation
  def show
    @current_case = CasaCase.find(params[:casa_case_id])
    @emancipation_form_data = EmancipationCategory.all.map { |category| {:category => category, :options => EmancipationOption.category_options(category.id)} }
  end

  # POST /casa_cases/:casa_case_id/emancipation/save
  def save
    if !params.key?("casa_case_id")
      render json: { error: "Missing param casa_case_id" }
      return
    elsif !/\A\d+\z/.match(params[:casa_case_id])
      render json: { error: "Param casa_case_id must be a positive integer" }
      return
    end

    if !params.key?("option_action")
      render json: { error: "Missing param option_action" }
      return
    end

    if !params.key?("option_id")
      render json: { error: "Missing param option_id" }
      return
    elsif !/\A\d+\z/.match(params[:option_id])
      render json: { error: "Param option_id must be a positive integer" }
      return
    end

    begin
      current_case = CasaCase.find(params[:casa_case_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Could not find case from id given by casa_case_id" }
      return
    end

    begin
      if params[:option_action] == "add"
        current_case.addEmancipationOption(params[:option_id])
        render json: "success".to_json
      elsif params[:option_action] == "delete"
        current_case.removeEmancipationOption(params[:option_id])
        render json: "success".to_json
      else
        render json: { error: "Param option_action did not contain a supported action" }
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Could not find option from id given by param option_id" }
    rescue ActiveRecord::RecordNotUnique
      render json: { error: "Option already added to case" }
    rescue StandardError => error
      render json: { error: error.message }
    end
  end
end
