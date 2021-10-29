class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    is_admin?
  end

  def show?
    is_admin?
  end

  def create?
    is_admin?
  end

  def new?
    is_admin?
  end

  def update?
    is_admin?
  end

  def edit?
    is_admin?
  end

  def destroy?
    is_admin?
  end

  def is_admin?
    user.casa_admin?
  end

  def is_supervisor?
    user.supervisor?
  end

  def is_volunteer?
    user.volunteer?
  end

  def admin_or_supervisor?
    is_admin? || is_supervisor?
  end

  def admin_or_supervisor_or_volunteer?
    admin_or_supervisor? || is_volunteer?
  end

  def see_reports_page?
    is_supervisor? || is_admin?
  end

  def see_emancipation_checklist?
    is_volunteer?
  end

  def see_court_reports_page?
    is_volunteer? || is_supervisor? || is_admin?
  end

  def see_mileage_rate? # TODO make these specific to casa orgs
    is_admin?
  end

  alias_method :modify_organization?, :is_admin?
  alias_method :see_import_page?, :is_admin?
end
