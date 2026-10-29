class CasaAdminPolicy < UserPolicy
  def index?
    is_admin?
  end

  alias_method :new?, :index?
  alias_method :create?, :index?
  alias_method :update?, :is_admin_same_org?
  alias_method :activate?, :is_admin_same_org?
  alias_method :resend_invitation?, :is_admin_same_org?
  alias_method :restore?, :is_admin_same_org?
  alias_method :change_to_supervisor?, :is_admin_same_org?

  def edit?
    is_admin_same_org?
  end

  def deactivate?
    see_deactivate_option? && same_org? && CasaAdmin.in_organization(current_organization).active.size > 1
  end

  def see_deactivate_option?
    is_admin? && user.active?
  end
end
