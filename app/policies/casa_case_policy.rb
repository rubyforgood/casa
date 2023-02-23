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
    is_supervisor_same_org? || is_admin_same_org?
  end

  def update_birth_month_year_youth?
    # View only policy?
    is_admin?
  end

  def update_date_in_care_youth?
    # View only policy?
    is_supervisor? || is_admin?
  end

  def update_emancipation_option?
    # This permission is used in the Emancipations controller
    is_in_same_org? && (
      admin_or_supervisor? || is_volunteer_actively_assigned_to_case?
    )
    # Proposed change:
    # admin_or_supervisor_same_org? || is_volunteer_actively_assigned_to_case?
  end

  def assign_volunteers?
    # is_in_same_org? && admin_or_supervisor? # Original
    admin_or_supervisor_same_org?
  end

  def can_see_filters?
    # View only policy?
    is_supervisor? || is_admin?
  end

  alias_method :update_case_number?, :is_admin_same_org?
  alias_method :update_case_status?, :is_admin? # Should this be scoped as well?
  alias_method :update_court_date?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :update_hearing_type?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :update_judge?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :update_court_report_due_date?, :admin_or_supervisor_or_volunteer_same_org?
  alias_method :update_court_orders?, :admin_or_supervisor_or_volunteer_same_org?

  def permitted_attributes
    common_attrs = [
      :court_report_submitted,
      :court_report_status,
      casa_case_contact_types_attributes: [:contact_type_id]
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
    # is_in_same_org? && admin_or_supervisor?
    admin_or_supervisor_same_org?
  end

  def index?
    # admin_or_supervisor_or_volunteer? # Original scope
    admin_or_supervisor_or_volunteer_same_org?
  end

  alias_method :show?, :same_org_supervisor_admin_or_assigned?
  alias_method :save_emancipation?, :index? # Should this be the same as edit?
  alias_method :edit?, :same_org_supervisor_admin_or_assigned?
  alias_method :update?, :same_org_supervisor_admin_or_assigned?
  alias_method :new?, :same_org_supervisor_admin?
  alias_method :create?, :same_org_supervisor_admin?
  alias_method :destroy?, :same_org_supervisor_admin?

  private

  # I think we should get rid of this method and rely on the application policy one.
  def is_in_same_org?
    # on new? checks, record is nil, on index policy_scope, record is :casa_case
    record.nil? || record == :casa_case || user.casa_org_id == record.casa_org_id
  end

  def is_volunteer_actively_assigned_to_case?
    return false if record.nil? # no record, no auth
    return false unless same_org?

    record.case_assignments.exists?(volunteer_id: user.id, active: true)
  end

  def case_court_orders_attributes
    {case_court_orders_attributes: %i[text implementation_status id]}
  end
end
