class AllCasaAdmins::DashboardController < AllCasaAdminsController
  def show
    @current_organizations = CasaOrg.all
  end
end
