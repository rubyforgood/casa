class AllCasaAdmins::CasaOrgsController < AllCasaAdminsController
  def show
    @casa_org = CasaOrg.find(params[:id])
  end

  def new
    @casa_org = CasaOrg.new
  end

  def create
    @casa_org = CasaOrg.new(casa_org_params)

    respond_to do |format|
      if @casa_org.save
        format.html { redirect_to all_casa_admins_casa_org_path(@casa_org), notice: "CASA Organization was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  private

  def casa_org_params
    params.require(:casa_org).permit(:name, :display_name, :address)
  end
end
