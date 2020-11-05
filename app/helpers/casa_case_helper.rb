module CasaCaseHelper
  def assigned_volunteers(casa_case)
    # TODO: make this more rails-ish
    Volunteer.joins(
      "left join case_assignments on case_assignments.volunteer_id = users.id"
    ).joins(
      "left join casa_cases on case_assignments.casa_case_id = casa_cases.id"
    ).where(
      "casa_cases.id = #{casa_case.id}"
    ).where(
      "users.active = true"
    ).where(
      "case_assignments.is_active = true"
    )
  end
end
