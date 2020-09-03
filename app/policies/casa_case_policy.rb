class CasaCasePolicy
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
      case @user
      when CasaAdmin # scope.in_casa_administered_by(@user)
        scope.ordered
      when Volunteer
        scope.actively_assigned_to(user)
      when Supervisor
        scope.ordered
      else
        raise "unrecognized user type #{@user.type}"
      end
    end
  end

  def update_case_number?
    user.is_a?(CasaAdmin)
  end

  def assign_volunteers?
    _is_supervisor_or_casa_admin?
  end

  def permitted_attributes
    case @user
    when CasaAdmin
      %i[case_number transition_aged_youth]
    else
      %i[transition_aged_youth]
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
    user.is_a?(CasaAdmin) || user.is_a?(Supervisor)
  end

  def _is_volunteer_actively_assigned_to_case?
    record.case_assignments.exists?(volunteer_id: user.id, is_active: true)
  end
end
