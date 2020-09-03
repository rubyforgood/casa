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
        scope.ordered.actively_assigned_to(user)
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
    is_in_same_org? && is_supervisor_or_casa_admin?
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
    is_in_same_org? && (
      is_supervisor_or_casa_admin? || is_volunteer_actively_assigned_to_case?
    )
  end

  def edit?
    is_in_same_org? && (
      is_supervisor_or_casa_admin? || is_volunteer_actively_assigned_to_case?
    )
  end

  def new?
    is_in_same_org? && is_supervisor_or_casa_admin?
  end

  def create?
    is_in_same_org? && is_supervisor_or_casa_admin?
  end

  def update?
    is_in_same_org? && (
      is_supervisor_or_casa_admin? || is_volunteer_actively_assigned_to_case?
    )
  end

  def destroy?
    is_in_same_org? && is_supervisor_or_casa_admin?
  end

  private

  def is_in_same_org?
    # on new? checks, record is nil, on index policy_scope, record is :casa_case
    record.nil? || record == :casa_case || user.casa_org_id == record.casa_org_id
  end

  def is_supervisor_or_casa_admin?
    user.is_a?(CasaAdmin) || user.is_a?(Supervisor)
  end

  def is_volunteer_actively_assigned_to_case?
    record.case_assignments.exists?(volunteer_id: user.id, is_active: true)
  end
end
