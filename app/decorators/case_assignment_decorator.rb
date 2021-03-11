class CaseAssignmentDecorator < Draper::Decorator
  delegate_all

  def unassigned_in_past_week?
    this_week = Date.today - 7.days..Date.today
    object.active == false && this_week.cover?(object.updated_at)
  end
end
