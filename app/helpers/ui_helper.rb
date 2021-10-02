module UiHelper
  def grouped_options_for_assigning_case(volunteer)
    [
      [
        "Not Assigned",
        CasaCase
          .not_assigned(@volunteer.casa_org).active
          .uniq { |casa_case| casa_case.case_number }
          .map { |casa_case| [casa_case.case_number, casa_case.id] }
      ],
      [
        "Assigned",
        CasaCase
          .actively_assigned_excluding_volunteer(@volunteer)
          .uniq { |casa_case| casa_case.case_number }
          .map { |casa_case| [casa_case.case_number, casa_case.id] }
      ]
    ]
  end
end
