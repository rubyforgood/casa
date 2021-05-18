class DashboardController < ApplicationController
  before_action :require_organization!
  after_action :verify_authorized

  def show
    authorize :dashboard
    if volunteer_with_only_one_active_case?
      redirect_to casa_case_path(current_user.casa_cases.active.first)
    elsif current_user.volunteer?
      redirect_to casa_cases_path
    elsif current_user.supervisor?
      redirect_to volunteers_path
    elsif current_user.casa_admin?
      redirect_to supervisors_path
    end
  end

  private

  def volunteer_with_only_one_active_case?
    current_user.volunteer? && current_user.casa_cases.active.count == 1
  end
end
