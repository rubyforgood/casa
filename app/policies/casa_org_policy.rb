class CasaOrgPolicy < ApplicationPolicy
  def edit?
    record.users.include?(user) && is_admin?
  end

  def update?
    record.users.include?(user) && is_admin?
  end
end
