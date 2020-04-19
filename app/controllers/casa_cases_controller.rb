# rubocop:todo Style/Documentation
class CasaCasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_casa_case, only: %i[show edit update destroy]

  # GET /casa_cases
  # GET /casa_cases.json
  def index
    @casa_cases = CasaCase.all
  end

  # GET /casa_cases/1
  # GET /casa_cases/1.json
  def show; end

  # GET /casa_cases/new
  def new
    @casa_case = CasaCase.new
  end

  # GET /casa_cases/1/edit
  def edit; end

  # POST /casa_cases
  # POST /casa_cases.json
  def create
    @casa_case = CasaCase.new(casa_case_params)

    respond_to do |format|
      if @casa_case.save
        format.html { redirect_to @casa_case, notice: 'CASA case was successfully created.' }
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
      if @casa_case.update(casa_case_params)
        format.html { redirect_to @casa_case, notice: 'CASA case was successfully updated.' }
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
      format.html { redirect_to casa_cases_url, notice: 'CASA case was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_casa_case
    @casa_case = CasaCase.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def casa_case_params
    params.require(:casa_case).permit(:case_number, :teen_program_eligible)
  end
end
# rubocop:enable Style/Documentation
