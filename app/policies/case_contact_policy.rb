class CaseContactPolicy
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def _is_creator_or_casa_admin?
    is_casa_admin_of_org?(user, record) || record.creator == user
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
    _is_creator_or_casa_admin?
  end

  def update?
    _is_creator_or_casa_admin?
  end

  def edit?
    _is_creator_or_casa_admin?
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
      case @user.role
      when 'casa_admin'
        # scope.in_casa_administered_by(@user)
        scope.all
      when 'volunteer'
        scope.where(casa_case: CasaCase.actively_assigned_to(@user), creator: @user)
      else
        raise "unrecognized role"
      end
    end
  end
end
