class VolunteerPolicy < UserPolicy
  def index?
   admin_or_supervisor?
  end

  def new?
    create?
  end

  def create?
    is_admin?
  end
end
