class CaseCourtOrderPolicy < ApplicationPolicy
  alias_method :destroy?, :admin_or_supervisor?

  def is_volunteer_assigned_to_case_for_court_order
    @record.casa_case.case_assignments.exists?(volunteer_id: @user.id, active: true)
  end
end
