class AllCasaAdmins::DashboardController < AllCasaAdminsController
  before_action -> { @active_nav = "organizations" }

  def show
    @organizations = CasaOrg.all
  end
end
