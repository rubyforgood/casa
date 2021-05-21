class PastCourtDatePolicy < ApplicationPolicy
  def show?
    casa_case_policy.edit?
  end

  private

  def casa_case_policy
    CasaCasePolicy.new(user, record.casa_case)
  end
end
