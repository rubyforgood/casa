class CasaOrgsController < ApplicationController # rubocop:todo Style/Documentation
  before_action :set_casa_org, only: %i[show edit update destroy]

  # GET /casa_orgs
  # GET /casa_orgs.json
  def index
    @casa_orgs = CasaOrg.all
  end

  # GET /casa_orgs/1
  # GET /casa_orgs/1.json
  def show; end

  # GET /casa_orgs/new
  def new
    @casa_org = CasaOrg.new
  end

  # GET /casa_orgs/1/edit
  def edit; end

  # POST /casa_orgs
  # POST /casa_orgs.json
  def create
    @casa_org = CasaOrg.new(casa_org_params)

    respond_to do |format|
      if @casa_org.save
        format.html { redirect_to @casa_org, notice: 'CASA org was successfully created.' }
        format.json { render :show, status: :created, location: @casa_org }
      else
        format.html { render :new }
        format.json { render json: @casa_org.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /casa_orgs/1
  # PATCH/PUT /casa_orgs/1.json
  def update
    respond_to do |format|
      if @casa_org.update(casa_org_params)
        format.html { redirect_to @casa_org, notice: 'CASA org was successfully updated.' }
        format.json { render :show, status: :ok, location: @casa_org }
      else
        format.html { render :edit }
        format.json { render json: @casa_org.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /casa_orgs/1
  # DELETE /casa_orgs/1.json
  def destroy
    @casa_org.destroy
    respond_to do |format|
      format.html { redirect_to casa_orgs_url, notice: 'CASA org was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_casa_org
    @casa_org = CasaOrg.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def casa_org_params
    params.require(:casa_org).permit(:name)
  end
end
