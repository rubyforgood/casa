class CasaAdminPolicy < UserPolicy
  def activate?
    is_admin?
  end

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
