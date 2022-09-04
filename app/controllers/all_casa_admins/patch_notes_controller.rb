class AllCasaAdmins::PatchNotesController < AllCasaAdminsController
  # GET /patch_notes or /patch_notes.json
  def index
    @patch_note_groups = PatchNoteGroup.all
    @patch_note_types = PatchNoteType.all
    @patch_notes = PatchNote.order(created_at: :desc)
  end

  # POST /patch_notes or /patch_notes.json
  def create
    @patch_note = PatchNote.new(patch_note_params)

    if @patch_note.save
      render json: {status: :created, id: @patch_note.id}, status: :created
    else
      render json: {errors: @patch_note.errors.full_messages.to_json}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /patch_notes/1 or /patch_notes/1.json
  def update
    @patch_note = PatchNote.find(params[:id])
    if @patch_note.update(patch_note_params)
      render json: {status: :ok}
    else
      render json: {errors: @patch_note.errors.full_messages.to_json}, status: :unprocessable_entity
    end
  end

  # DELETE /patch_notes/1 or /patch_notes/1.json
  def destroy
    @patch_note = PatchNote.find(params[:id])

    if @patch_note.destroy
      render json: {status: :ok}
    else
      render json: {errors: @patch_note.errors.full_messages.to_json}, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_patch_note
    @patch_note = PatchNote.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def patch_note_params
    params.permit(:note, :patch_note_group_id, :patch_note_type_id)
  end
end
