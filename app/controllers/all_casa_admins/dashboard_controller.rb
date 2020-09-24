class AllCasaAdmins::DashboardController < AllCasaAdminsController
  def show
    @organizations = CasaOrg.all
  end
end
