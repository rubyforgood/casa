class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :dashboard

    # Return all active/inactive volunteers, inactive will be filtered by default
    @volunteers = policy_scope(
      Volunteer.includes(:case_assignments, :casa_cases, versions: [:item])).decorate

    @casa_cases = policy_scope(CasaCase.includes(:case_assignments, :volunteers).all)

    @case_contacts = policy_scope(
      CaseContact.all
    ).order(occurred_at: :desc).decorate

    @supervisors = policy_scope(Supervisor.all)
  end
end
