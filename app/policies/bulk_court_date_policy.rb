class BulkCourtDatePolicy < ApplicationPolicy
  # https://github.com/varvet/pundit#headless-policies
  # record will be `:bulk_court_date`

  def new?
    admin_or_supervisor?
  end

  def create?
    admin_or_supervisor?
  end
end
