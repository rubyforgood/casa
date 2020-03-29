class CasaCasePolicy # rubocop:todo Style/Documentation
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def _is_casa_admin_of_case_org?
    user.is_instance?(CasaAdmin) && (record.casa_org == user.casa_org)
  end

  def index?
    _is_casa_admin_of_case_org?
  end

  def show?
    _is_casa_admin_of_case_org?
  end

  def create?
    _is_casa_admin_of_case_org?
  end

  def new?
    _is_casa_admin_of_case_org?
  end

  def update?
    _is_casa_admin_of_case_org?
  end

  def edit?
    _is_casa_admin_of_case_org?
  end

  def destroy?
    _is_casa_admin_of_case_org?
  end
end
