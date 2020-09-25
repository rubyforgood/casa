class CasaAdminPolicy < UserPolicy
  def index?
    user.casa_admin?
  end
end
