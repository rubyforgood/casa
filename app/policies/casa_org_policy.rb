class CasaOrgPolicy # rubocop:todo Style/Documentation
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def _is_all_casa_admin?
    user.is_instance? AllCasaAdmin
  end

  def index?
    _is_all_casa_admin?
  end

  def show?
    _is_all_casa_admin?
  end

  def create?
    _is_all_casa_admin?
  end

  def new?
    _is_all_casa_admin?
  end

  def update?
    _is_all_casa_admin?
  end

  def edit?
    _is_all_casa_admin?
  end

  def destroy?
    _is_all_casa_admin?
  end
end
