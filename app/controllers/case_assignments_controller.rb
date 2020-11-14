class CaseAssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor # admins and supervisors can create/delete ALL case assignments
  before_action :load_case_assignment, only: %i[destroy unassign]

  def create
    case_assignments = case_assignment_parent.case_assignments
    existing_case_assignment = case_assignments.where(volunteer_id: case_assignment_params[:volunteer_id], is_active: false).first

    if existing_case_assignment.present?
      if existing_case_assignment.update(is_active: true)
        flash.notice = "Volunteer reassigned to case"
      else
        errors = existing_case_assignment.errors.full_messages.join(". ")
        flash.alert = "Unable to reassigned volunteer to case: #{errors}."
      end
    else
      case_assignment = case_assignment_parent.case_assignments.new(case_assignment_params)
      if case_assignment.save
        flash.notice = "Volunteer assigned to case"
      else
        errors = case_assignment.errors.full_messages.join(". ")
        flash.alert = "Unable to assign volunteer to case: #{errors}."
      end
    end

    redirect_to after_action_path(case_assignment_parent)
  end

  def destroy
    @case_assignment.destroy

    redirect_to after_action_path(case_assignment_parent)
  end

  def unassign
    authorize @case_assignment, :unassign?
    casa_case = @case_assignment.casa_case
    volunteer = @case_assignment.volunteer
    flash_message = "Volunteer was unassigned from Case #{casa_case.case_number}."

    if @case_assignment.update(is_active: false)
      if params[:redirect_to_path] == "volunteer"
        redirect_to edit_volunteer_path(volunteer), notice: flash_message
      else
        redirect_to after_action_path(casa_case), notice: flash_message
      end
    else
      render :edit
    end
  end

  private

  def case_assignment_parent
    if params[:volunteer_id]
      User.find(params[:volunteer_id])
    else
      CasaCase.find(params[:casa_case_id])
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
