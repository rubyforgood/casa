class PlacementPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless @user&.casa_org

      scope.joins(:casa_case).where(casa_cases: {casa_org: @user.casa_org})
    end
  end

  def allowed_to_edit_casa_case?
    casa_case_policy.edit?
  end

  alias_method :show?, :allowed_to_edit_casa_case?
  alias_method :edit?, :allowed_to_edit_casa_case?
  alias_method :update?, :allowed_to_edit_casa_case?
  alias_method :new?, :allowed_to_edit_casa_case?
  alias_method :create?, :allowed_to_edit_casa_case?
  alias_method :destroy?, :admin_or_supervisor?

  private

  def casa_case_policy
    CasaCasePolicy.new(user, record.casa_case)
  end
end
