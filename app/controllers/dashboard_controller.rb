class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :dashboard

    # Return all active/inactive volunteers, inactive will be filtered by default
    @volunteers = policy_scope(
      User.includes(:case_assignments, :casa_cases, versions: [:item])
          .where(role: %w[inactive volunteer])
    ).decorate

    @casa_cases = policy_scope(CasaCase.includes(:case_assignments, :volunteers).all)

    @case_contacts = policy_scope(
      CaseContact.all
    ).order(occurred_at: :desc).decorate
  end
end
