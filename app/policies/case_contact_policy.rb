class CaseContactPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    # Everyone is allowed to create a case_contact
    true
  end

  def _is_creator_or_casa_admin?
    _is_admin? || _is_creator?
  end

  def _is_creator_or_supervisor_or_casa_admin?
    _is_admin? || _is_creator? || _is_creator_supervisor?
  end

  alias_method :index?, :_is_creator_or_casa_admin?
  alias_method :show?, :_is_creator_or_casa_admin?
  alias_method :create?, :_is_creator_or_casa_admin?
  alias_method :destroy?, :_is_creator_or_casa_admin?
  alias_method :update?, :_is_creator_or_supervisor_or_casa_admin?
  alias_method :edit?, :_is_creator_or_supervisor_or_casa_admin?

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

  def _is_admin?
    user.casa_admin?
  end

  def _is_creator_supervisor?
    record.creator&.supervisor == user
  end

  def _is_creator?
    record.creator == user
  end
end
