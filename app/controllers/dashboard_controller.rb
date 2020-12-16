class DashboardController < ApplicationController
  before_action :require_organization!
  after_action :verify_authorized

  def show
    authorize :dashboard
    if current_user.volunteer?
      redirect_to casa_cases_path
    elsif current_user.supervisor?
      redirect_to volunteers_path
    else # casa admin
      redirect_to supervisors_path
    end
  end
end
