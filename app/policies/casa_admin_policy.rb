class CasaAdminPolicy < UserPolicy
  def index?
    user.casa_admin?
  end

  def deactivate?
    show_deactivate_option? && CasaAdmin.in_organization(current_organization).active.size > 1
  end

  def see_deactivate_option?
    user.casa_admin? && user.active?
  end

  private

  def current_organization
    current_user&.casa_org
  end
end
