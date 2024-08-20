class PlacementPolicy < ApplicationPolicy
  def allowed_to_edit_casa_case?
    casa_case_policy.edit?
  end

  alias index? admin_or_supervisor_or_volunteer_same_org?
  alias show? admin_or_supervisor_or_volunteer_same_org?
  alias edit? allowed_to_edit_casa_case?
  alias update? allowed_to_edit_casa_case?
  alias new? admin_or_supervisor_or_volunteer_same_org?
  alias create? allowed_to_edit_casa_case?
  alias destroy? admin_or_supervisor?

  private

  def casa_case_policy
    CasaCasePolicy.new(user, record.casa_case)
  end
end
