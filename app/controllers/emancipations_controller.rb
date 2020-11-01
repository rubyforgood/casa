class EmancipationsController < ApplicationController
  before_action :authenticate_user!

  # GET /casa_cases/:casa_case_id/emancipation
  def show
    @case_options = CasaCase.find(params[:casa_case_id]).emancipation_options
    @emancipation_form_data = EmancipationCategory.all.map { |category| {:category => category, :options => EmancipationOption.category_options(category.id)} }
  end

  # POST /casa_cases/:casa_case_id/emancipation/save
  def save
    current_case = CasaCase.find(params[:casa_case_id])
    option_action = params[:option_action]
    if option_action == "add"
      current_case.addEmancipationOption(params[:option_id])
    elsif option_action == "delete"
      current_case.removeEmancipationOption(params[:option_id])
    else
    end
  end
end
