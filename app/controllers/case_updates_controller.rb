class CaseUpdatesController < ApplicationController
  before_action :set_case_update, only: %i[show edit update destroy]

  # GET /case_updates
  # GET /case_updates.json
  def index
    @case_updates = CaseUpdate.all
  end

  # GET /case_updates/1
  # GET /case_updates/1.json
  def show; end

  # GET /case_updates/new
  def new
    @case_update = CaseUpdate.new
  end

  # GET /case_updates/1/edit
  def edit; end

  # POST /case_updates
  # POST /case_updates.json
  def create
    @case_update = CaseUpdate.new(case_update_params)

    respond_to do |format|
      if @case_update.save
        format.html { redirect_to @case_update, notice: 'Case update was successfully created.' }
        format.json { render :show, status: :created, location: @case_update }
      else
        format.html { render :new }
        format.json { render json: @case_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /case_updates/1
  # PATCH/PUT /case_updates/1.json
  def update
    respond_to do |format|
      if @case_update.update(case_update_params)
        format.html { redirect_to @case_update, notice: 'Case update was successfully updated.' }
        format.json { render :show, status: :ok, location: @case_update }
      else
        format.html { render :edit }
        format.json { render json: @case_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /case_updates/1
  # DELETE /case_updates/1.json
  def destroy
    @case_update.destroy
    respond_to do |format|
      format.html { redirect_to case_updates_url, notice: 'Case update was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_case_update
    @case_update = CaseUpdate.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def case_update_params
    params.require(:case_update).permit(:user_id, :casa_case_id, :update_type, :other_type_text)
  end
end
