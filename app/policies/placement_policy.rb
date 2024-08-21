class PlacementPolicy < ApplicationPolicy
  def allowed_to_edit_casa_case?
    casa_case_policy.edit?
  end

  alias_method :index?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :show?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :edit?, :allowed_to_edit_casa_case?
  alias_method :update?, :allowed_to_edit_casa_case?
  alias_method :new?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :create?, :allowed_to_edit_casa_case?
  alias_method :destroy?, :admin_or_supervisor?

  private

  def casa_case_policy
    CasaCasePolicy.new(user, record.casa_case)
  end
end
