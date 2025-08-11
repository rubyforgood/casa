module LoadsCaseContacts
  extend ActiveSupport::Concern

  private

  def load_case_contacts
    authorize CaseContact

    @current_organization_groups = current_organization_groups

    @filterrific = initialize_filterrific(
      all_case_contacts,
      params[:filterrific],
      select_options: {
        sorted_by: CaseContact.options_for_sorted_by
      }
    ) || return

    @pagy, @filtered_case_contacts = pagy(@filterrific.find)
    case_contacts = CaseContact.case_hash_from_cases(@filtered_case_contacts)
    case_contacts = case_contacts.select { |k, _v| current_user.casa_cases.pluck(:id).include?(k) } if current_user.volunteer?
    case_contacts = case_contacts.select { |k, _v| k == params[:casa_case_id].to_i } if params[:casa_case_id].present?

    @presenter = CaseContactPresenter.new(case_contacts)
  end

  private

  def current_organization_groups
    current_organization.contact_type_groups
      .includes(:contact_types)
      .joins(:contact_types)
      .where(contact_types: {active: true})
      .uniq
  end

  def all_case_contacts
    policy_scope(current_organization.case_contacts).preload(
      :creator,
      :followups,
      contact_types: :contact_type_group,
      contact_topic_answers: :contact_topic,
      casa_case: :volunteers
    )
  end
end
