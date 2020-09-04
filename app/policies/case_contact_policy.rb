class CaseContactPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    _is_creator_or_casa_admin?
  end

  def show?
    _is_creator_or_casa_admin?
  end

  def create?
    _is_creator_or_casa_admin?
  end

  def new?
    # Everyone should be allowed to create a case_contact
    true
  end

  def update?
    _is_creator_or_supervisor_or_casa_admin?
  end

  def edit?
    _is_creator_or_supervisor_or_casa_admin?
  end

  def destroy?
    _is_creator_or_casa_admin?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case @user
      when CasaAdmin # scope.in_casa_administered_by(@user)
        scope.all
      when Volunteer
        scope.where(casa_case: CasaCase.actively_assigned_to(@user), creator: @user)
      when Supervisor
        scope.all
      else
        raise "unrecognized user type #{@user.type}"
      end
    end
  end

  private

  def _is_creator_or_casa_admin?
    _is_admin? || _is_creator?
  end

  def _is_creator_or_supervisor_or_casa_admin?
    _is_admin? || _is_supervisor? || _is_creator?
  end

  def _is_admin?
    user.casa_admin?
  end

  def _is_supervisor?
    user.supervisor?
  end

  def _is_creator?
    record.creator == user
  end
end
