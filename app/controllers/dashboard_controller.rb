class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_organization!

  def show
    if current_user.volunteer?
      redirect_to casa_cases_path
    elsif current_user.supervisor?
      redirect_to volunteers_path
    else # casa admin
      redirect_to supervisors_path
    end
  end
end
