class PlacementPolicy < ApplicationPolicy
  def allowed_to_edit_casa_case?
    casa_case_policy.edit?
  end

  alias index? allowed_to_edit_casa_case?
  alias show? allowed_to_edit_casa_case?
  alias edit? allowed_to_edit_casa_case?
  alias update? allowed_to_edit_casa_case?
  alias new? allowed_to_edit_casa_case?
  alias create? allowed_to_edit_casa_case?
  alias destroy? admin_or_supervisor?

  private

  def casa_case_policy
    CasaCasePolicy.new(user, record.casa_case)
  end
end
