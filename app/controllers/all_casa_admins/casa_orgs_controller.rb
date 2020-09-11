class AllCasaAdmins::CasaOrgsController < AllCasaAdminsController
  def show
    @casa_org = CasaOrg.find(params[:id])
  end
end
