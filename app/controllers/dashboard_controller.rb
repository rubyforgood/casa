class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :dashboard

    @casa_cases = policy_scope(current_organization.casa_cases.includes(:case_assignments, :volunteers))

    @case_contacts = policy_scope(CaseContact.where(
      casa_case_id: @casa_cases.map(&:id)
    )).order(occurred_at: :desc).decorate

    @supervisors = policy_scope(current_organization.supervisors)
    @admins = policy_scope(current_organization.casa_admins).sort_by(&:email)
  end
end
