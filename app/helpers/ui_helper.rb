module UiHelper
  include VolunteerHelper

  def grouped_options_for_assigning_case(volunteer)
    [
      [
        "Not Assigned",
        CasaCase
          .not_assigned(@volunteer.casa_org).active
          .uniq { |casa_case| casa_case.case_number }
          .map { |casa_case| ["#{casa_case.case_number} - #{volunteer_badge(casa_case, current_user)}".html_safe, casa_case.id] }
      ],
      [
        "Assigned",
        CasaCase
          .actively_assigned_excluding_volunteer(@volunteer)
          .uniq { |casa_case| casa_case.case_number }
          .map { |casa_case| ["#{casa_case.case_number} - #{volunteer_badge(casa_case, current_user)}".html_safe, casa_case.id] }
      ]
    ]
  end

  def contact_types_list(reimbursement)
    reimbursement
      .contact_groups_with_types
      .map { |cg, types_arr| "#{cg} (#{types_arr.join(", ")})" }
      .join(", ")
  end
end
