class SupervisorVolunteersController < ApplicationController
  after_action :verify_authorized

  def create
    authorize :supervisor_volunteer
    supervisor_volunteer = supervisor_volunteer_parent.supervisor_volunteers.find_or_create_by!(supervisor_volunteer_params)
    supervisor_volunteer.is_active = true unless supervisor_volunteer&.is_active?
    volunteer = supervisor_volunteer.volunteer
    supervisor = supervisor_volunteer.supervisor
    supervisor_volunteer.save
    flash_message = "#{volunteer.display_name} successfully assigned to #{supervisor.display_name}."

    redirect_to request.referer, notice: flash_message
  end

  def unassign
    authorize :supervisor_volunteer
    volunteer = Volunteer.find(params[:id])
    supervisor_volunteer = volunteer.supervisor_volunteer
    supervisor = volunteer.supervisor
    supervisor_volunteer.is_active = false
    supervisor_volunteer.save!
    flash_message = "#{volunteer.display_name} was unassigned from #{supervisor.display_name}."

    redirect_to request.referer, notice: flash_message
  end

  private

  def supervisor_volunteer_params
    params.require(:supervisor_volunteer).permit(:supervisor_id, :volunteer_id)
  end

  def supervisor_volunteer_parent
    Supervisor.find(params[:supervisor_id] || supervisor_volunteer_params[:supervisor_id])
  end
end
