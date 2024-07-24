class SupervisorVolunteersController < ApplicationController
  after_action :verify_authorized

  def create
    authorize :supervisor_volunteer
    volunteer = Volunteer.find(supervisor_volunteer_params[:volunteer_id])
    supervisor = set_supervisor
    if assign_volunteer_to_supervisor(volunteer, supervisor)
      flash[:notice] = "#{volunteer.display_name} successfully assigned to #{supervisor.display_name}."
    else
      flash[:alert] = "Something went wrong. Please try again."
    end

    redirect_to request.referer
  end

  def unassign
    authorize :supervisor_volunteer
    volunteer = Volunteer.find(params[:id])
    if unassign_volunteers_supervisor(volunteer)
      supervisor = volunteer.supervisor_volunteer.supervisor
      flash[:notice] = "#{volunteer.display_name} was unassigned from #{supervisor.display_name}."
    else
      flash[:alert] = "Something went wrong. Please try again."
    end

    redirect_to request.referer
  end

  def bulk_assignment
    authorize :supervisor_volunteer

    volunteers = policy_scope(current_organization.volunteers).where(id: params[:supervisor_volunteer][:volunteer_ids])
    supervisor = policy_scope(current_organization.supervisors).where(id: params[:supervisor_volunteer][:supervisor_id]).first
    if bulk_change_supervisor(supervisor, volunteers)
      flash[:notice] = "#{"Volunteer".pluralize(volunteers.count)} successfully assigned to new supervisor."
    else
      flash[:alert] = "Something went wrong. The #{"volunteer".pluralize(volunteers.count)} could not be assigned."
    end

    redirect_to volunteers_path
  end

  private

  def supervisor_volunteer_params
    params.require(:supervisor_volunteer).permit(:supervisor_id, :volunteer_id, volunteer_ids: [])
  end

  def set_supervisor
    Supervisor.find(params[:supervisor_id] || supervisor_volunteer_params[:supervisor_id])
  end

  def bulk_change_supervisor(supervisor, volunteers)
    if supervisor
      volunteers.each do |volunteer|
        assign_volunteer_to_supervisor(volunteer, supervisor)
      end
    else
      volunteers.each do |volunteer|
        unassign_volunteers_supervisor(volunteer)
      end
    end
  end

  def assign_volunteer_to_supervisor(volunteer, supervisor)
    unassign_volunteers_supervisor(volunteer)
    supervisor_volunteer = supervisor.supervisor_volunteers.find_or_create_by!(volunteer: volunteer)
    supervisor_volunteer.update!(is_active: true)
  end

  def unassign_volunteers_supervisor(volunteer)
    volunteer.supervisor_volunteer&.update(is_active: false)
  end
end
