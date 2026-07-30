class LearningHoursDashboardRowsService
  # `range` (a Date range or nil) bounds the per-volunteer totals on the supervisor/admin roster.
  # nil means all time. A volunteer's own list is not aggregated, so the range does not apply there.
  def initialize(user, learning_hours_scope, range = nil)
    @user = user
    @learning_hours_scope = learning_hours_scope
    @range = range
  end

  def perform
    case @user
    when Volunteer
      @learning_hours_scope
    when Supervisor
      supervisor_rows
    when CasaAdmin
      LearningHour.all_volunteers_learning_hours(@user.casa_org_id, @range)
    else
      raise "unrecognized role #{@user.type}"
    end
  end

  private

  def supervisor_rows
    totals_by_user_id =
      LearningHour
        .supervisor_volunteers_learning_hours(@user.id, @range)
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
