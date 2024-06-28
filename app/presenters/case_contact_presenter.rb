class CaseContactPresenter < BasePresenter
  attr_reader :case_contacts
  attr_reader :casa_cases

  def initialize(case_contacts)
    @case_contacts = case_contacts
    @casa_cases = policy_scope(org_cases).group_by(&:id).transform_values(&:first)
  end

  def display_case_number(casa_case_id)
    if casa_cases[casa_case_id]&.case_number.present?
      "#{casa_cases[casa_case_id].decorate.transition_aged_youth_icon} #{casa_cases[casa_case_id].case_number}"
    else
      ""
    end
  end

  def boolean_select_options
    [
      ["Yes", true],
      ["No", false]
    ]
  end

  private

  def org_cases
    CasaOrg.includes(:casa_cases)
      .references(:casa_cases)
      .find_by(id: current_user.casa_org_id)
      .casa_cases
  end
end
