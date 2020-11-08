class ApplicationPolicy
  attr_reader :user

  def initialize(user, _application)
    @user = user
  end

  def see_reports_page?
    user.supervisor? || user.casa_admin?
  end

  def see_emancipation_checklist?
    user.volunteer?
  end

  def see_import_page?
    user.casa_admin?
  end

  def see_court_reports_page?
    user.volunteer?
  end

  def modify_organization?
    user.casa_admin?
  end
end
