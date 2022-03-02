class CaseCourtOrderPolicy < ApplicationPolicy
  alias_method :destroy?, :admin_or_supervisor_or_volunteer?
end
