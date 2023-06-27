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

    redirect_to request.referrer, notice: flash_message
  end

  def unassign
    authorize :supervisor_volunteer
    volunteer = Volunteer.find(params[:id])
    supervisor_volunteer = volunteer.supervisor_volunteer
    supervisor = volunteer.supervisor
    supervisor_volunteer.is_active = false
    supervisor_volunteer.save!
    flash_message = "#{volunteer.display_name} was unassigned from #{supervisor.display_name}."

    redirect_to request.referrer, notice: flash_message
  end

  def bulk_assignment
    
    volunteer_ids = params[:volunteer_ids]
    supervisor_id = params[:supervisor_volunteer][:supervisor_id].to_i
    errors = []
    created_volunteers = []
    supervisor = Supervisor.find_by_id(supervisor_id)
    volunteer_ids.each do |vol_id|
      authorize :supervisor_volunteer
      supervisor_volunteer = SupervisorVolunteer.new(volunteer_id: vol_id.to_i, supervisor_id: supervisor_id)
      if supervisor_volunteer.save
        supervisor_volunteer.is_active = true unless supervisor_volunteer&.is_active?
        volunteer = supervisor_volunteer.volunteer 
        created_volunteers << "#{volunteer.display_name}"
      else 
        errors << "Volunteer not Assigned"
      end 
    end 
    flash_message = "#{created_volunteers} were assigned to #{supervisor.display_name}"
    redirect_to request.referrer, notice: flash_message
  end 

  private

  def supervisor_volunteer_params
    params.require(:supervisor_volunteer).permit(:supervisor_id, :volunteer_id)
  end

  def supervisor_volunteer_parent
    Supervisor.find(params[:supervisor_id] || supervisor_volunteer_params[:supervisor_id])
  end

  def bulk_assignment_params 
    params.require(:supervisor_volunteer).permit(:volunteer_ids, :supervisor_id)
  end 
end
