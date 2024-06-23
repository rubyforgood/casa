class CustomLinkPolicy < ApplicationPolicy
  alias_method :create?, :is_admin_same_org?
  alias_method :edit?, :is_admin_same_org?
  alias_method :new?, :is_admin_same_org?
  alias_method :show?, :is_admin_same_org?
  alias_method :update?, :is_admin_same_org?
  alias_method :soft_delete?, :is_admin_same_org?
end
