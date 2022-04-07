class NotesController < ApplicationController
  before_action :find_note, only: %i[edit update]
  before_action :find_volunteer

  def create
    @volunteer.notes.create(note_params)
    redirect_to edit_volunteer_path(@volunteer)
  end

  def edit
  end

  def update
    @note.update(note_params)

    redirect_to edit_volunteer_path(@volunteer)
  end

  private

  def find_note
    @note = Note.find(params[:id])
  end

  def find_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id])
  end

  def note_params
    params.require(:note).permit(:content).merge({creator_id: current_user.id})
  end
end
