class CasaOrgPolicy < ApplicationPolicy
  def edit?
    record.users.include?(user) && is_admin?
  end

  def update?
    record.users.include?(user) && is_admin?
  end

  def same_org?
    user&.casa_org.present? && user.casa_org == record
  end
end
