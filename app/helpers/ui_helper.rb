module UiHelper
  def return_to_dashboard_button
    link_to "Return to Dashboard", root_path, {class: "btn btn-info pull-right"}
  end

  def grouped_options_for_assigning_case(volunteer)
    [
      [
        "Not Assigned",
        CasaCase
          .not_assigned(@volunteer.casa_org).active
          .map { |casa_case| [casa_case.case_number, casa_case.id] }
      ],
      [
        "Assigned",
        CasaCase
          .actively_assigned_excluding_volunteer(@volunteer)
          .map { |casa_case| [casa_case.case_number, casa_case.id] }
      ]
    ]
  end
end
