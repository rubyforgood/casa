class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :dashboard

    # Return all active/inactive volunteers, inactive will be filtered by default
    @volunteers = policy_scope(
      current_organization.volunteers.includes(:versions, :supervisor, :casa_cases, case_assignments: [:casa_case]).references(:supervisor, :casa_cases)
    ).decorate

    @casa_cases = policy_scope(current_organization.casa_cases.includes(:case_assignments, :volunteers))

    @case_contacts = policy_scope(CaseContact.where(
      casa_case_id: @casa_cases.map(&:id)
    )).order(occurred_at: :desc).decorate

    @supervisors = policy_scope(current_organization.supervisors)
  end
end
