class CasaCasePolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case @user
      when CasaAdmin, Supervisor
        scope.by_organization(@user.casa_org)
      when Volunteer
        scope.actively_assigned_to(user)
      else
        raise "unrecognized user type #{@user.type}"
      end
    end

    def sibling_cases
      case @user
      when CasaAdmin, Supervisor
        user.casa_org.casa_cases.excluding(scope)
      when Volunteer
        user.casa_cases.excluding(scope)
      else
        raise "unrecognized user type #{@user.type}"
      end
    end
  end

  def update_contact_types?
    admin_or_supervisor_same_org?
  end

  def update_birth_month_year_youth?
    is_admin_same_org?
  end

  def update_date_in_care_youth?
    admin_or_supervisor_same_org?
  end

  def update_emancipation_option?
    # This permission is used in the Emancipations controller
    admin_or_supervisor_same_org? || is_volunteer_actively_assigned_to_case?
  end

  def assign_volunteers?
    admin_or_supervisor_same_org?
  end

  def can_see_filters?
    admin_or_supervisor?
  end

  alias_method :update_case_number?, :is_admin_same_org?
  alias_method :update_case_status?, :is_admin_same_org?
  alias_method :update_court_date?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :update_hearing_type?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :update_judge?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :update_court_report_due_date?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :update_court_orders?, :admin_or_supervisor_or_volunteer_same_org?

  def permitted_attributes
    common_attrs = [
      :court_report_submitted,
      :court_report_status,
      contact_type_ids: []
    ]

    case @user
    when CasaAdmin
      common_attrs.concat(
        %i[case_number birth_month_year_youth court_date court_report_due_date hearing_type_id judge_id date_in_care]
      )
      common_attrs << case_court_orders_attributes
    when Supervisor
      common_attrs.concat(%i[court_date court_report_due_date hearing_type_id judge_id date_in_care])
      common_attrs << case_court_orders_attributes
    when Volunteer
      common_attrs.concat(%i[court_date court_report_due_date hearing_type_id judge_id])
      common_attrs << case_court_orders_attributes
    else
      common_attrs
    end
  end

  def same_org_supervisor_admin_or_assigned?
    admin_or_supervisor_same_org? || is_volunteer_actively_assigned_to_case?
  end

  def same_org_supervisor_admin?
    admin_or_supervisor_same_org?
  end

  def index?
    admin_or_supervisor_or_volunteer?
  end

  alias_method :show?, :same_org_supervisor_admin_or_assigned?
  alias_method :save_emancipation?, :index? # Should this be the same as edit?
  alias_method :edit?, :same_org_supervisor_admin_or_assigned?
  alias_method :update?, :same_org_supervisor_admin_or_assigned?
  alias_method :new?, :is_admin_same_org?
  alias_method :create?, :is_admin_same_org?
  alias_method :destroy?, :is_admin_same_org?

  private

  def is_volunteer_actively_assigned_to_case?
    return false if record.nil? # no record, no auth
    return false unless same_org?

    record.case_assignments.exists?(volunteer_id: user.id, active: true)
  end

  def case_court_orders_attributes
    {case_court_orders_attributes: %i[text implementation_status id _destroy]}
  end
end
