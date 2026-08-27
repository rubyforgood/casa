class AllCasaAdmins::DashboardController < AllCasaAdminsController
  before_action -> { @active_nav = "organizations" }

  def show
    @organizations = CasaOrg.all
    @user_counts = CasaOrg.user_count_by_org_id
    @case_contacts_counts = CasaOrg.case_contacts_count_by_org_id
  end
end
