class ImportPolicy < ApplicationPolicy
  def index?
    user.casa_admin?
  end

  alias_method :create?, :index?
  alias_method :download_failed?, :index?
end
