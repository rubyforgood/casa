class LearningHoursDashboardRowsService
  def initialize(user, learning_hours_scope)
    @user = user
    @learning_hours_scope = learning_hours_scope
  end

  def perform
    case @user
    when Volunteer
      @learning_hours_scope
    when Supervisor
      supervisor_rows
    when CasaAdmin
      LearningHour.all_volunteers_learning_hours(@user.casa_org_id)
    else
      raise "unrecognized role #{@user.type}"
    end
  end

  private

  def supervisor_rows
    totals_by_user_id =
      LearningHour
        .supervisor_volunteers_learning_hours(@user.id)
        .index_by { |row| row.user_id }

    @user.volunteers.map do |volunteer|
      totals_by_user_id[volunteer.id] || OpenStruct.new(
        user_id: volunteer.id,
        display_name: volunteer.display_name,
        total_time_spent: 0
      )
    end
  end
end
