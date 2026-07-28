class CaseContactsDecorator < Draper::CollectionDecorator
  def display_case_number(casa_case_id)
    casa_case = casa_cases[casa_case_id]

    if casa_cases[casa_case&.id]&.case_number.present?
      "#{casa_case.decorate.transition_aged_youth_icon} #{casa_case.case_number}"
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

  def casa_cases
    h.policy_scope(org_cases).group_by(&:id).transform_values(&:first)
  end

  def org_cases
    CasaOrg.find(h.current_user.casa_org_id).casa_cases.active
  end
end
