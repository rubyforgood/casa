class CasaAdminPolicy < UserPolicy
  def index?
    is_admin?
  end

  alias_method :new?, :index?
  alias_method :create?, :index?
  alias_method :edit?, :index?
  alias_method :update?, :index?
  alias_method :activate?, :index?
  alias_method :resend_invitation?, :index?
  alias_method :restore?, :is_admin?
  alias_method :datatable?, :index?

  def deactivate?
    see_deactivate_option? && CasaAdmin.in_organization(current_organization).active.size > 1
  end

  def see_deactivate_option?
    is_admin? && user.active?
  end

  private

  def current_organization
    user&.casa_org
  end
end
