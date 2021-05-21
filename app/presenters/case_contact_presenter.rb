class CaseContactPresenter < BasePresenter
  def casa_cases
    @casa_cases ||= policy_scope(org_cases).group_by(&:id).transform_values(&:first)
  end

  def case_contacts
    @case_contacts ||= case_contact_with_deleted.sort_by do |contact|
      [contact.casa_case_id, Time.current - contact.occurred_at]
    end.group_by(&:casa_case_id)
  end

  def display_case_number(casa_case_id)
    "#{casa_cases[casa_case_id].decorate.transition_aged_youth_icon} #{casa_cases[casa_case_id].case_number}"
  end

  private

  def case_contact_with_deleted
    policy_scope(
      current_organization.case_contacts
                                         .grab_all(current_user)
                                         .includes(:creator, contact_types: :contact_type_group)
    )
      .order("contact_types.id asc")
      .decorate
  end

  def org_cases
    CasaOrg.includes(:casa_cases)
      .references(:casa_cases)
      .find_by(id: current_user.casa_org_id)
      .casa_cases.includes(:case_contacts)
  end
end
