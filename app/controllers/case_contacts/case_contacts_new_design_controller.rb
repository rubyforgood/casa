class CaseContacts::CaseContactsNewDesignController < ApplicationController
  include LoadsCaseContacts

  before_action :check_feature_flag

  # Sortable columns on the casa_app table (server-side ?sort=/?direction=).
  SORT_COLUMNS = %w[occurred_at medium_type contact_made].freeze

  def index
    authorize CaseContact
    @active_nav = "contacts"
    @current_organization_groups = current_organization_groups
    @filterable_cases = current_organization.casa_cases.order(:case_number)
    @sort = SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "occurred_at"
    @direction = (params[:direction] == "asc") ? "asc" : "desc"

    scope = filter_case_contacts(policy_scope(current_organization.case_contacts))
      .includes(:casa_case, :contact_types, :contact_topics, :followups, :creator, contact_topic_answers: :contact_topic)
    order = Arel.sql("case_contacts.#{@sort} #{@direction} NULLS LAST, case_contacts.id DESC")
    @pagy, @case_contacts = pagy(scope.order(order))

    render layout: "casa_app"
  end

  private

  # Maps the plain GET filter params to the CaseContact scopes. Contact type is a subquery so
  # multi-type contacts are never duplicated by the join.
  def filter_case_contacts(scope)
    scope = scope.occurred_starting_at(params[:occurred_starting_at])
    scope = scope.occurred_ending_at(params[:occurred_ending_at])
    scope = scope.with_casa_case(params[:casa_case_ids]) if params[:casa_case_ids].present?
    if params[:contact_type_ids].present?
      scope = scope.where(id: CaseContact.joins(:contact_types).where(contact_types: {id: params[:contact_type_ids]}))
    end
    scope = scope.contact_medium(params[:contact_medium])
    scope = scope.contact_made(params[:contact_made])
    scope = scope.no_drafts(1) if params[:no_drafts].present?
    scope
  end

  def check_feature_flag
    unless Flipper.enabled?(:new_case_contact_table)
      redirect_to case_contacts_path, alert: "This feature is not available."
    end
  end
end
