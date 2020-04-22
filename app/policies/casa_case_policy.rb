class CasaCasePolicy
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case @user.role
      when 'casa_admin' # scope.in_casa_administered_by(@user)
        scope.ordered
      when 'volunteer'
        scope.actively_assigned_to(user)
      else
        raise 'unrecognized role'
      end
    end
  end

  def update_case_number?
    user.casa_admin?
  end

  def permitted_attributes
    case @user.role
    when 'casa_admin'
      %i[case_number teen_program_eligible]
    else
      %i[teen_program_eligible]
    end
  end

  def show?
    _is_supervisor_or_casa_admin? || _is_volunteer_actively_assigned_to_case?
  end

  def edit?
    _is_supervisor_or_casa_admin? || _is_volunteer_actively_assigned_to_case?
  end

  def new?
    _is_supervisor_or_casa_admin?
  end

  def create?
    _is_supervisor_or_casa_admin?
  end

  def update?
    _is_supervisor_or_casa_admin? || _is_volunteer_actively_assigned_to_case?
  end

  def destroy?
    _is_supervisor_or_casa_admin?
  end

  private

  def _is_supervisor_or_casa_admin?
    user.casa_admin? || user.supervisor?
  end

  def _is_volunteer_actively_assigned_to_case?
    record.case_assignments.exists?(volunteer_id: user.id, is_active: true)
  end
end
