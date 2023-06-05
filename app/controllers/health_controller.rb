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
end
