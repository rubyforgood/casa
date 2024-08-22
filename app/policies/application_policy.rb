class ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError
    end
  end

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

  def same_org?
    # NOTE: must have casa_org association on a Policy's associated Model
    # that is: `has_one :casa_org, through: :some_association` (may need to define :some_association)
    # do not use for collection actions (index), check user type & use policy_scope() on the collection
    user&.casa_org.present? && user.casa_org == record&.casa_org
  end

  def is_admin_same_org?
    # eventually everything should use this
    user.casa_admin? && same_org?
  end

  def is_supervisor?
    user.supervisor?
  end

  def is_supervisor_same_org?
    # eventually everything should use this
    user.supervisor? && same_org?
  end

  def is_volunteer? # deprecated in favor of is_volunteer_same_org?
    user.volunteer?
  end

  def is_volunteer_same_org?
    user.volunteer? && same_org?
  end

  def admin_or_supervisor?
    is_admin? || is_supervisor?
  end

  def admin_or_supervisor_same_org?
    # eventually everything should use this
    is_admin_same_org? || is_supervisor_same_org?
  end

  def admin_or_supervisor_or_volunteer?
    admin_or_supervisor? || is_volunteer?
  end

  def admin_or_supervisor_or_volunteer_same_org?
    admin_or_supervisor_same_org? || is_volunteer_same_org?
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

  def see_mileage_rate?
    is_admin? && reimbursement_enabled? # && matches_casa_org? # TODO do this *in* is_admin - what might that break?
  end

  def matches_casa_org?
    @record&.casa_org == @user&.casa_org && !@record.casa_org.nil?
  end

  def reimbursement_enabled?
    current_organization&.show_driving_reimbursement
  end

  def current_organization
    user&.casa_org
  end

  alias_method :modify_organization?, :is_admin?
  alias_method :see_import_page?, :is_admin?
  alias_method :see_banner_page?, :admin_or_supervisor?
end
