class CaseAssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor # admins and supervisors can create/delete ALL case assignments

  def create
    case_assignment = case_assignment_parent.case_assignments.new(case_assignment_params)
    case_assignment.save

    redirect_to after_action_path(case_assignment_parent)
  end

  def destroy
    case_assignment = CaseAssignment.find(params[:id])
    case_assignment.destroy

    redirect_to after_action_path(case_assignment_parent)
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
end
