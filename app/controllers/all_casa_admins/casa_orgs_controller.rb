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
      @casa_org.generate_defaults
      respond_to do |format|
        format.html do
          redirect_to all_casa_admins_casa_org_path(@casa_org),
            notice: "CASA Organization was successfully created."
        end

        format.json do
          render json: @casa_org, status: :created
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @casa_org.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def casa_org_params
    params.require(:casa_org).permit(:name, :display_name, :address)
  end
end
