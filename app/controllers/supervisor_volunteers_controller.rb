class SupervisorVolunteersController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor, only: :destroy

  def create
    supervisor_volunteer = supervisor_volunteer_parent.supervisor_volunteers.new(supervisor_volunteer_params)
    supervisor_volunteer.save

    redirect_to after_action_path(supervisor_volunteer_parent)
  end

  def destroy
    supervisor_volunteer = SupervisorVolunteer.find(params[:id])
    supervisor = supervisor_volunteer.supervisor
    supervisor_volunteer.delete

    redirect_to after_action_path(supervisor)
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
