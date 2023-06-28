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

  def bulk_assignment
    authorize :supervisor_volunteer
    if mass_assign_volunteers?
      volunteer_ids = supervisor_volunteer_params[:volunteer_ids]
      supervisor = supervisor_volunteer_params[:supervisor_id]
      vol = "Volunteer".pluralize(volunteer_ids.length)

      if supervisor == "unassign"
        name_array = bulk_unassign!(volunteer_ids)
        flash_message = "#{vol} #{name_array.to_sentence} successfully unassigned"
      else
        supervisor = supervisor_volunteer_parent
        name_array = bulk_assign!(supervisor, volunteer_ids)
        flash_message = "#{vol} #{name_array.to_sentence} successfully reassigned to #{supervisor.display_name}"
      end

      redirect_to volunteers_path, notice: flash_message
    else
      redirect_to volunteers_path, notice: "Please select at least one volunteer and one supervisor."
    end
  end

  private

  def supervisor_volunteer_params
    params.require(:supervisor_volunteer).permit(:supervisor_id, :volunteer_id, volunteer_ids: [])
  end

  def supervisor_volunteer_parent
    Supervisor.find(params[:supervisor_id] || supervisor_volunteer_params[:supervisor_id])
  end

  def mass_assign_volunteers?
    supervisor_volunteer_params[:volunteer_ids] && supervisor_volunteer_params[:supervisor_id] ? true : false
  end

  def bulk_assign!(supervisor, volunteer_ids)
    created_volunteers = []
    volunteer_ids.each do |vol_id|
      if (supervisor_volunteer = SupervisorVolunteer.find_by(volunteer_id: vol_id.to_i))
        supervisor_volunteer.update!(supervisor_id: supervisor.id)
      else
        supervisor_volunteer = supervisor.supervisor_volunteers.create(volunteer_id: vol_id.to_i)
      end
      supervisor_volunteer.is_active = true
      volunteer = supervisor_volunteer.volunteer
      supervisor_volunteer.save
      created_volunteers << volunteer.display_name.to_s
    end
    created_volunteers
  end

  def bulk_unassign!(volunteer_ids)
    unassigned_volunteers = []
    volunteer_ids.each do |vol_id|
      supervisor_volunteer = SupervisorVolunteer.find_by(volunteer_id: vol_id.to_i)
      supervisor_volunteer.update(is_active: false)
      volunteer = supervisor_volunteer.volunteer
      supervisor_volunteer.save
      unassigned_volunteers << volunteer.display_name.to_s # take into account single assignments and give multiple assignments proper format
    end
    unassigned_volunteers
  end
end
