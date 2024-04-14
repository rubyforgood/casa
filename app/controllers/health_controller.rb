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
    case_contacts_created_in_last_week = CaseContact.where("created_at >= ?", 1.week.ago)

    unix_timestamps_of_case_contacts_created_in_last_week = case_contacts_created_in_last_week.pluck(:created_at).map { |creation_time| creation_time.to_i }

    render json: {timestamps: unix_timestamps_of_case_contacts_created_in_last_week}
  end

  def monthly_line_graph_data
    first_day_of_last_12_months = (12.months.ago.to_date..Date.current).select { |date| date.day == 1 }.map { |date| date.beginning_of_month }

    monthly_counts_of_case_contacts_created = CaseContact.group_by_month(:created_at, last: 12).count
    monthly_counts_of_case_contacts_with_notes_created = CaseContact.left_outer_joins(:contact_topic_answers).where("case_contacts.notes != '' OR contact_topic_answers.value != ''").select(:id).distinct.group_by_month(:created_at, last: 12).count
    monthly_counts_of_users_who_have_created_case_contacts = CaseContact.select(:creator_id).distinct.group_by_month(:created_at, last: 12).count

    monthly_line_graph_combined_data = first_day_of_last_12_months.map do |month|
      [
        month.strftime("%b %Y"),
        monthly_counts_of_case_contacts_created[month],
        monthly_counts_of_case_contacts_with_notes_created[month],
        monthly_counts_of_users_who_have_created_case_contacts[month]
      ]
    end

    render json: monthly_line_graph_combined_data
  end

  def monthly_unique_users_graph_data
    first_day_of_last_12_months = (12.months.ago.to_date..Date.current).select { |date| date.day == 1 }.map { |date| date.beginning_of_month }

    monthly_counts_of_volunteers = User.where(type: "Volunteer").group_by_month(:current_sign_in_at, format: "%b %Y").count
    monthly_counts_of_supervisors = User.where(type: "Supervisor").group_by_month(:current_sign_in_at, format: "%b %Y").count
    monthly_counts_of_casa_admins = User.where(type: "CasaAdmin").group_by_month(:current_sign_in_at, format: "%b %Y").count

    monthly_line_graph_combined_data = first_day_of_last_12_months.map do |month|
      [
        month.strftime("%b %Y"),
        monthly_counts_of_volunteers[month.strftime("%b %Y")] || 0,
        monthly_counts_of_supervisors[month.strftime("%b %Y")] || 0,
        monthly_counts_of_casa_admins[month.strftime("%b %Y")] || 0
      ]
    end

    render json: monthly_line_graph_combined_data
  end
end
