class NotesController < ApplicationController
  def create
    volunteer = Volunteer.find(params[:volunteer_id])
    volunteer.notes.create(note_params)
    redirect_to edit_volunteer_path(volunteer)
  end

  private

  def note_params
    params.require(:note).permit(:content).merge({creator_id: current_user.id})
  end
end
