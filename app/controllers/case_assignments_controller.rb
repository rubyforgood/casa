class CaseAssignmentsController < ApplicationController
  before_action :set_case_assignment, only: %i[show edit update destroy]

  # GET /case_assignments
  # GET /case_assignments.json
  def index
    @case_assignments = CaseAssignment.all
  end

  # GET /case_assignments/1
  # GET /case_assignments/1.json
  def show; end

  # GET /case_assignments/new
  def new
    @case_assignment = CaseAssignment.new
  end

  # GET /case_assignments/1/edit
  def edit; end

  # POST /case_assignments
  # POST /case_assignments.json
  def create
    @case_assignment = CaseAssignment.new(case_assignment_params)

    respond_to do |format|
      if @case_assignment.save
        format.html { redirect_to @case_assignment, notice: 'Case assignment was successfully created.' }
        format.json { render :show, status: :created, location: @case_assignment }
      else
        format.html { render :new }
        format.json { render json: @case_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /case_assignments/1
  # PATCH/PUT /case_assignments/1.json
  def update
    respond_to do |format|
      if @case_assignment.update(case_assignment_params)
        format.html { redirect_to @case_assignment, notice: 'Case assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @case_assignment }
      else
        format.html { render :edit }
        format.json { render json: @case_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /case_assignments/1
  # DELETE /case_assignments/1.json
  def destroy
    @case_assignment.destroy
    respond_to do |format|
      format.html { redirect_to case_assignments_url, notice: 'Case assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_case_assignment
    @case_assignment = CaseAssignment.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def case_assignment_params
    params.require(:case_assignment).permit(:volunteer_id, :casa_case_id, :is_active)
  end
end
