class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :dashboard

    # Return all active/inactive volunteers, inactive will be filtered by default
    @volunteers = policy_scope(
      current_organization.volunteers.includes(:supervisor, :case_assignments, :case_contacts, :casa_cases, versions: [:item])
    ).decorate

    @casa_cases = policy_scope(current_organization.casa_cases.includes(:case_assignments, :volunteers, :case_contacts))

    @case_contacts = policy_scope(CaseContact.where(
      casa_case_id: @casa_cases.map(&:id)
    )).order(occurred_at: :desc).decorate

    @supervisors = policy_scope(current_organization.supervisors.includes(:supervisor_volunteers, :volunteers))
  end
end
