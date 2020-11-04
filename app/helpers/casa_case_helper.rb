module CasaCaseHelper
  def assigned_volunteers(casa_case)
    casa_case.case_assignments.filter_map { |assignment| assignment.volunteer if assignment.is_active }
  end
end