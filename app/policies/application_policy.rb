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

  def is_admin?
    user.casa_admin?
  end

  def see_court_reports_page?
    user.volunteer?
  end

  alias_method :modify_organization?, :is_admin?
  alias_method :see_import_page?, :is_admin?
end
