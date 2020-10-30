class EmancipationsController < ApplicationController
  before_action :authenticate_user!

  # GET /casa_cases/:casa_case_id/emancipation
  def show
   @case_options = params[:casa_case_id]
   @emancipation_form_data = EmancipationCategory.all.map { |category| {:category => category, :options => EmancipationOption.categoryOptions(category.id)} }
  end

  # POST /casa_cases/:casa_case_id/emancipation/save
  def save
  end
end
