class AllCasaAdmins::CasaOrgsController < AllCasaAdminsController
  def show
    @casa_org = CasaOrg.find(params[:id])
    @casa_org_metrics = AllCasaAdmins::CasaOrgMetrics.new(@casa_org).metrics
  end

  def new
    @casa_org = CasaOrg.new
  end

  def create
    @casa_org = CasaOrg.new(casa_org_params)

    if @casa_org.save
      redirect_to all_casa_admins_casa_org_path(@casa_org), notice: "CASA Organization was successfully created."
    else
      render :new, notice: @casa_org.errors.full_messages
    end
  end

  private

  def casa_org_params
    params.require(:casa_org).permit(:name, :display_name, :address)
  end
end
