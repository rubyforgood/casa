class AllCasaAdmins::CasaAdminsController < AllCasaAdminsController
  before_action :set_casa_org

  def new
    @casa_admin = CasaAdmin.new
  end

  def create
    service = ::CreateCasaAdminService.new(@casa_org, params, current_user)
    @casa_admin = service.build
    begin
      service.create!
      redirect_to all_casa_admins_casa_org_path(@casa_org), notice: "New admin created successfully"
    rescue ActiveRecord::RecordInvalid
      render :new
    end
  end

  def edit
    @casa_admin = CasaAdmin.find(params[:id])
  end

  def update
    @casa_admin = CasaAdmin.find(params[:id])

    if @casa_admin.update(all_casa_admin_params)
      if @casa_admin.saved_changes.include?("unconfirmed_email")
        redirect_to edit_all_casa_admins_casa_org_casa_admin_path(@casa_org), notice: "Confirmation Email Sent To Casa Admin."
      else
        @casa_admin.filter_old_emails!(@casa_admin.email)
        redirect_to edit_all_casa_admins_casa_org_casa_admin_path(@casa_org), notice: "Casa Admin was successfully updated."
      end
    else
      render :edit
    end
  end

  def activate
    @casa_admin = CasaAdmin.find(params[:id])
    if @casa_admin.activate
      CasaAdminMailer.account_setup(@casa_admin).deliver

      redirect_to edit_all_casa_admins_casa_org_casa_admin_path, notice: "Admin was activated. They have been sent an email."
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
    # @casa_org = CasaOrg.find_by(slug: params[:casa_org_id]) # TODO when using slugs
  end
end
