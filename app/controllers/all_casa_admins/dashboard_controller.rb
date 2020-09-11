class AllCasaAdmins::DashboardController < AllCasaAdminsController
  def show
    @casa_orgs = CasaOrg.all
  end
end
