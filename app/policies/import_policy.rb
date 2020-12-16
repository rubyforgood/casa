class ImportPolicy < Struct.new(:user, :record)
  def index?
    user.casa_admin?
  end

  alias_method :create?, :index?
  alias_method :download_failed?, :index?
end
