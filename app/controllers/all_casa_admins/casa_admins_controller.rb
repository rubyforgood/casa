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

  def edit
    @casa_admin = CasaAdmin.find(params[:id])
  end

  def update
    @casa_admin = CasaAdmin.find(params[:id])
    if @casa_admin.update(all_casa_admin_params)
      redirect_to edit_all_casa_admins_casa_org_casa_admin_path, notice: "Admin was successfully updated."
    else
      render :edit
    end
  end

  def activate
    @casa_admin = CasaAdmin.find(params[:id])
    if @casa_admin.activate
      CasaAdminMailer.account_setup(@casa_admin).deliver

      redirect_to edit_all_casa_admins_casa_org_casa_admin_path, notice: "Admin was activated."
    else
      render :edit
    end
  end

  def deactivate
    @casa_admin = CasaAdmin.find(params[:id])
    if @casa_admin.deactivate
      CasaAdminMailer.deactivation(@casa_admin).deliver

      redirect_to edit_all_casa_admins_casa_org_casa_admin_path, notice: "Admin was deactivated."
    else
      render :edit
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
