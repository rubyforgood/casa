class VolunteerPolicy < UserPolicy
  def index?
    admin_or_supervisor?
  end

  alias_method :datatable?, :index?
  alias_method :new?, :index?
  alias_method :create?, :index?
  alias_method :edit?, :index?
  alias_method :update?, :index?
  alias_method :activate?, :index?
  alias_method :deactivate?, :index?
  alias_method :resend_invitation?, :index?
  alias_method :reminder?, :index?
end
