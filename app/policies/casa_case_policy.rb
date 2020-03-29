class CasaCasePolicy # rubocop:todo Style/Documentation
  attr_reader :user, :casa_case

  def initialize(user, casa_case)
    @user = user
    @casa_case = casa_case
  end

  def update?
    user.volunteer? || user.supervisor? || user.casa_admin?
    # user.casa_admin? or _user_is_supervisor_of_volunteer_for_case?(user) or _user_is_volunteer_assigned_to_case(user) # for the future when we have all the models
  end

  def _user_is_supervisor_of_volunteer_for_case?(user)
    # for the future when we have all the models
    # user.supervisor? and user.supervisor_volunteers.any?(casa_case.case_assignments.map(&:volunteer_user))
  end

  def _user_is_volunteer_assigned_to_case(user)
    # user.case_assignments.map(&:casa_case).includes?(@casa_case)
  end
end
