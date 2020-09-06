class CasaCasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_casa_case, only: %i[show edit update destroy]
  before_action :require_organization!

  # GET /casa_cases
  # GET /casa_cases.json
  def index
    org_cases = CasaOrg.includes(:casa_cases).references(:casa_cases).find_by(id: current_user.casa_org_id).casa_cases
    @casa_cases = policy_scope(org_cases)
  end

  # GET /casa_cases/1
  # GET /casa_cases/1.json
  def show
    authorize @casa_case
  end

  # GET /casa_cases/new
  def new
    @casa_case = CasaCase.new(casa_org: current_organization)
    authorize @casa_case
  end

  # GET /casa_cases/1/edit
  def edit
    authorize @casa_case
  end

  # POST /casa_cases
  # POST /casa_cases.json
  def create
    @casa_case = CasaCase.new(casa_case_params.merge(casa_org: current_organization))

    respond_to do |format|
      if @casa_case.save
        format.html { redirect_to @casa_case, notice: "CASA case was successfully created." }
        format.json { render :show, status: :created, location: @casa_case }
      else
        format.html { render :new }
        format.json { render json: @casa_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /casa_cases/1
  # PATCH/PUT /casa_cases/1.json
  def update
    respond_to do |format|
      if @casa_case.update(casa_case_update_params)
        format.html { redirect_to edit_casa_case_path, notice: "CASA case was successfully updated." }
        format.json { render :show, status: :ok, location: @casa_case }
      else
        format.html { render :edit }
        format.json { render json: @casa_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /casa_cases/1
  # DELETE /casa_cases/1.json
  def destroy
    @casa_case.destroy
    respond_to do |format|
      format.html { redirect_to casa_cases_url, notice: "CASA case was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_casa_case
    @casa_case = current_organization.casa_cases.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  # Only allow a list of trusted parameters through.
  def casa_case_params
    params.require(:casa_case).permit(:case_number, :transition_aged_youth)
  end

  # Separate params so only admins can update the case_number
  def casa_case_update_params
    params.require(:casa_case).permit(policy(@casa_case).permitted_attributes)
  end
end
