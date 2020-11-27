class SupervisorVolunteersController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor, only: :unassign

  def create
    supervisor_volunteer = supervisor_volunteer_parent.supervisor_volunteers.find_or_create_by!(supervisor_volunteer_params)
    supervisor_volunteer.is_active = true unless supervisor_volunteer&.is_active?
    supervisor_volunteer.save

    redirect_to after_action_path(supervisor_volunteer_parent)
  end

  def unassign
    volunteer = Volunteer.find(params[:id])
    supervisor_volunteer = volunteer.supervisor_volunteer
    supervisor = volunteer.supervisor
    supervisor_volunteer.is_active = false
    supervisor_volunteer.save!
    flash_message = "#{volunteer.display_name} was unassigned from #{supervisor.display_name}."

    redirect_to after_action_path(supervisor), notice: flash_message
  end

  private

  def supervisor_volunteer_params
    params.require(:supervisor_volunteer).permit(:supervisor_id, :volunteer_id)
  end

  def after_action_path(resource)
    if resource.supervisor?
      edit_supervisor_path(resource)
    else
      edit_volunteer_path(resource)
    end
  end

  def supervisor_volunteer_parent
    if params[:supervisor_id]
      Supervisor.find(params[:supervisor_id])
    else
      Volunteer.find(params[:volunteer_id])
    end
  end
end
