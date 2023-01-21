class CaseAssignmentsController < ApplicationController
  before_action :load_case_assignment, only: %i[destroy unassign show_hide_contacts]
  after_action :verify_authorized

  def create
    authorize CaseAssignment
    case_assignments = case_assignment_parent.case_assignments
    existing_case_assignment = if params[:volunteer_id]
      case_assignments.where(casa_case_id: case_assignment_params[:casa_case_id], active: false).first
    else
      case_assignments.where(volunteer_id: case_assignment_params[:volunteer_id], active: false).first
    end

    if existing_case_assignment.present?
      if existing_case_assignment.update(active: true)
        message = "Volunteer reassigned to case"
        flash.notice = message
        status = :ok
      else
        errors = existing_case_assignment.errors.full_messages.join(". ")
        message = "Unable to reassigned volunteer to case: #{errors}."
        flash.alert = message
        status = :unprocessable_entity
      end
    else
      case_assignment = case_assignment_parent.case_assignments.new(case_assignment_params)
      if case_assignment.save
        message = "Volunteer assigned to case"
        flash.notice = message
        status = :ok
      else
        errors = case_assignment.errors.full_messages.join(". ")
        message = "Unable to assign volunteer to case: #{errors}."
        flash.alert = message
        status = :unprocessable_entity
      end
    end

    respond_to do |format|
      format.html { redirect_to after_action_path(case_assignment_parent) }
      format.json { render json: message, status: status }
    end
  end

  # TODO don't delete this, just deactivate it
  def destroy
    authorize @case_assignment
    @case_assignment.destroy

    redirect_to after_action_path(case_assignment_parent)
  end

  def unassign
    authorize @case_assignment, :unassign?
    casa_case = @case_assignment.casa_case
    volunteer = @case_assignment.volunteer
    message = "Volunteer was unassigned from Case #{casa_case.case_number}."

    if @case_assignment.update(active: false)
      if params[:redirect_to_path] == "volunteer"
        redirect_to edit_volunteer_path(volunteer), notice: message
      else
        respond_to do |format|
          format.html { redirect_to after_action_path(casa_case), notice: message }
          format.json { render json: message, status: :ok }
        end
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @case_assignment.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def show_hide_contacts
    authorize @case_assignment, :show_or_hide_contacts?
    casa_case = @case_assignment.casa_case
    volunteer = @case_assignment.volunteer

    flash_message = "Old Case Contacts created by #{volunteer.display_name} #{@case_assignment.hide_old_contacts? ? "are now visible" : "were successfully hidden"}."

    if !@case_assignment.active && @case_assignment.update(hide_old_contacts: !@case_assignment.hide_old_contacts?)
      redirect_to after_action_path(casa_case), notice: flash_message
    else
      render :edit
    end
  end

  private

  def case_assignment_parent
    if params[:volunteer_id]
      User.find(params[:volunteer_id])
    else
      CasaCase.friendly.find(params[:casa_case_id])
    end
  end

  def after_action_path(resource)
    if resource.is_a? User
      edit_volunteer_path(resource)
    else
      edit_casa_case_path(resource)
    end
  end

  def case_assignment_params
    params.require(:case_assignment).permit(:casa_case_id, :volunteer_id)
  end

  def load_case_assignment
    @case_assignment =
      CaseAssignment
        .joins(:casa_case)
        .where(casa_cases: {casa_org_id: current_organization.id})
        .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
