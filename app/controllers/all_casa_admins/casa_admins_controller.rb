class AllCasaAdmins::CasaAdminsController < AllCasaAdminsController
  before_action :set_casa_org

  def new
    @casa_admin = CasaAdmin.new
  end

  def create
    @casa_admin = CasaAdmin.new(casa_admin_params)
    @casa_admin.casa_org = @casa_org
    @casa_admin.password = SecureRandom.hex(10)

    if @casa_admin.save
      # TODO: Invite?
      redirect_to all_casa_admins_casa_org_path(@casa_org), notice: "CASA Admin was successfully created."
    else
      render :new
    end
  end

  private

  def set_casa_org
    @casa_org = CasaOrg.find(params[:casa_org_id])
  end

  def casa_admin_params
    params.require(:casa_admin).permit(:email, :display_name)
  end
end
