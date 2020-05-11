class CaseAssignmentsController < ApplicationController
  # NOTE: I don't know what auth levels to use here, but am pretty certain it needs SOMETHING.
  before_action :authenticate_user!
  before_action :must_be_admin

  def create
    volunteer = User.find(params[:volunteer_id])
    case_assignment = volunteer.case_assignments.new(case_assignment_params)

    case_assignment.save

    redirect_to edit_volunteer_path(volunteer)
  end

  def destroy
    volunteer = User.find(params[:volunteer_id])
    case_assignment = volunteer.case_assignments.find(params[:id])

    case_assignment.destroy

    redirect_to edit_volunteer_path(volunteer)
  end

  private

  def case_assignment_params
    params.require(:case_assignment).permit(:casa_case_id)
  end
end
