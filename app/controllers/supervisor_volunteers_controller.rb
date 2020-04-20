class SupervisorVolunteersController < ApplicationController
  before_action :set_supervisor_volunteer, only: %i[show edit update destroy]

  # GET /supervisor_volunteers
  # GET /supervisor_volunteers.json
  def index
    @supervisor_volunteers = SupervisorVolunteer.all
  end

  # GET /supervisor_volunteers/1
  # GET /supervisor_volunteers/1.json
  def show; end

  # GET /supervisor_volunteers/new
  def new
    @supervisor_volunteer = SupervisorVolunteer.new
  end

  # GET /supervisor_volunteers/1/edit
  def edit; end

  # POST /supervisor_volunteers
  # POST /supervisor_volunteers.json
  def create
    @supervisor_volunteer = SupervisorVolunteer.new(supervisor_volunteer_params)

    respond_to do |format|
      if @supervisor_volunteer.save
        format.html { redirect_to @supervisor_volunteer, notice: 'Supervisor volunteer was successfully created.' }
        format.json { render :show, status: :created, location: @supervisor_volunteer }
      else
        format.html { render :new }
        format.json { render json: @supervisor_volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supervisor_volunteers/1
  # PATCH/PUT /supervisor_volunteers/1.json
  def update
    respond_to do |format|
      if @supervisor_volunteer.update(supervisor_volunteer_params)
        format.html { redirect_to @supervisor_volunteer, notice: 'Supervisor volunteer was successfully updated.' }
        format.json { render :show, status: :ok, location: @supervisor_volunteer }
      else
        format.html { render :edit }
        format.json { render json: @supervisor_volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supervisor_volunteers/1
  # DELETE /supervisor_volunteers/1.json
  def destroy
    @supervisor_volunteer.destroy
    respond_to do |format|
      format.html { redirect_to supervisor_volunteers_url, notice: 'Supervisor volunteer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_supervisor_volunteer
    @supervisor_volunteer = SupervisorVolunteer.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def supervisor_volunteer_params
    params.require(:supervisor_volunteer).permit(:volunteer_id, :supervisor_id)
  end
end
