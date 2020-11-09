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
      when CasaAdmin, Supervisor
        scope
      when Volunteer
        scope.actively_assigned_to(user)
      else
        raise "unrecognized user type #{@user.type}"
      end
    end
  end

  def update_case_number?
    user.is_a?(CasaAdmin)
  end

  def update_contact_types?
    user.is_a?(Supervisor)
  end

  def update_case_status?
    user.is_a?(CasaAdmin)
  end

  def update_court_date?
    user.casa_admin? || user.supervisor?
  end

  def update_hearing_type?
    user.casa_admin? || user.supervisor?
  end

  def update_judge?
    user.casa_admin? || user.supervisor?
  end

  def update_court_report_due_date?
    user.casa_admin? || user.supervisor?
  end

  def update_birth_month_year_youth?
    user.casa_admin?
  end

  def assign_volunteers?
    is_in_same_org? && is_supervisor_or_casa_admin?
  end

  def permitted_attributes
    common_attrs = [
      :court_report_submitted,
      :court_report_status,
      casa_case_contact_types_attributes: [:contact_type_id]
    ]

    case @user
    when CasaAdmin
      common_attrs.concat(%i[case_number birth_month_year_youth court_date court_report_due_date hearing_type_id judge_id])
    when Supervisor
      common_attrs.concat(%i[court_date court_report_due_date hearing_type_id judge_id])
    else
      common_attrs
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

  def index?
    user.casa_admin? || user.supervisor? || user.volunteer?
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
