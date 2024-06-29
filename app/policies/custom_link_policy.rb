class CustomLinkPolicy < ApplicationPolicy
  alias create? is_admin_same_org?
  alias edit? is_admin_same_org?
  alias new? is_admin_same_org?
  alias show? is_admin_same_org?
  alias update? is_admin_same_org?
  alias destroy? is_admin_same_org?
end
