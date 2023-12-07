class HealthController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def index
    respond_to do |format|
      format.html do
        render :index
      end

      format.json { render json: {latest_deploy_time: Health.instance.latest_deploy_time} }
    end
  end

  def case_contacts_creation_times_in_last_week
    # Get the case contacts created in the last week
    case_contacts = CaseContact.where("created_at >= ?", 10.week.ago)

    # Extract the created_at timestamps and convert them to Unix time
    timestamps = case_contacts.pluck(:created_at).map { |t| t.to_i }

    # Return the timestamps as a JSON response
    render json: {timestamps: timestamps}
  end

  def case_contacts_creation_times_in_last_year
    # Generate an array of the last 12 months
    last_12_months = (11.months.ago.to_date..Date.current).map { |date| date.beginning_of_month }

    # Fetch case contact counts, counts with notes updated, and counts of users for each month
    data = CaseContact.group_by_month(:created_at, last: 12).count
    data_with_notes = CaseContact.where("notes != ''").group_by_month(:created_at, last: 12).count
    users_data = CaseContact.select(:creator_id).distinct.group_by_month(:created_at, last: 12).count

    # Combine the counts for each month
    chart_data = last_12_months.map do |month|
      count_all = data[month] || 0
      count_with_notes = data_with_notes[month] || 0
      count_users = users_data[month] || 0

      [month.strftime("%b %Y"), count_all, count_with_notes, count_users]
    end

    chart_data = chart_data.uniq!

    render json: chart_data
  end
end
