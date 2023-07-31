class ReimbursementsController < ApplicationController
  def new
  end

  def index
    authorize :reimbursement

    @complete_status = params[:status] == "complete"
    @datatable_url = datatable_reimbursements_path(format: :json, status: params[:status])
    @volunteers_for_filter = volunteers_for_filter(
      fetch_filtered_reimbursements(@complete_status)
    )
    @occurred_at_filter_start_date = (Time.now - 1.year).strftime("%Y/%m/%d")
    # @grouped_reimbursements = @reimbursements.group_by { |cc| "#{cc.occurred_at}-#{cc.creator_id}" }
  end

  def datatable
    authorize :reimbursement

    @complete_status = params[:status] == "complete"
    datatable = ReimbursementDatatable.new(
      fetch_filtered_reimbursements(@complete_status), params
    )

    render json: datatable
  end

  def change_complete_status
    authorize :reimbursement

    @case_contact = fetch_reimbursements.find(params[:reimbursement_id])
    @grouped_case_contacts = fetch_reimbursements
      .where({occurred_at: @case_contact.occurred_at, creator_id: @case_contact.creator_id})
    @grouped_case_contacts.update_all(reimbursement_params.to_h)
    ReimbursementCompleteNotification.with(case_contact: @case_contact).deliver(
      [@case_contact.creator, @case_contact.supervisor]
    )
    redirect_to reimbursements_path unless params[:ajax]
  end

  private

  def apply_filters_to_query(query)
    query = query.where(creator_id: params[:volunteers]) if params[:volunteers]

    apply_occurred_at_filters(query)
  end

  def apply_occurred_at_filters(query)
    return query unless params[:occurred_at]

    apply_occurred_at_filter(
      :start,
      apply_occurred_at_filter(:end, query)
    )
  end

  def apply_occurred_at_filter(key, query)
    return query if params[:occurred_at][key].empty?

    query.where(
      key == :end ? "? >= occurred_at" : "occurred_at >= ?",
      get_normalised_time_for_occurred_at_filter(key)
    )
  rescue ArgumentError
    query
  end

  def fetch_reimbursements
    case_contacts = CaseContact.joins(:casa_case).includes(
      :creator,
      :case_contact_contact_type,
      contact_types: [:contact_type_group]
    ).preload(:casa_case)
    policy_scope(case_contacts, policy_scope_class: ReimbursementPolicy::Scope)
  end

  def fetch_filtered_reimbursements(complete_only)
    apply_filters_to_query(
      fetch_reimbursements
        .want_driving_reimbursement(true)
        .created_max_ago(1.year.ago)
        .filter_by_reimbursement_status(complete_only)
    )
  end

  def get_normalised_time_for_occurred_at_filter(key)
    normalised_date = Date.strptime(params[:occurred_at][key], "%Y/%m/%d")
    normalised_time = DateTime.new(normalised_date.year, normalised_date.month, normalised_date.day)

    return normalised_time if key == :start

    normalised_time + 1.day - 1 * 10e-6.seconds if key == :end
  end

  def reimbursement_params
    params.require(:case_contact).permit(:reimbursement_complete)
  end

  def volunteers_for_filter(reimbursements)
    reimbursements
      .map { |reimbursement| [reimbursement.creator.id, reimbursement.creator.display_name] }
      .sort_by { |_, name| name }
      .to_h
  end
end
