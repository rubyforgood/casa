class AllCasaAdmins::DashboardController < ApplicationController
  def show
    @casa_orgs = CasaOrg.all
  end
end
