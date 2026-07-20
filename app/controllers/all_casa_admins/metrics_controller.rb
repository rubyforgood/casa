class AllCasaAdmins::MetricsController < AllCasaAdminsController
  before_action -> { @active_nav = "metrics" }

  def index
    @range = MetricsReport.clamp_range(params[:range])
    report = MetricsReport.new
    @case_contacts = report.monthly_case_contacts(@range)
    @active_users = report.monthly_active_users(@range)
    @contact_heatmap = report.contact_creation_heatmap(@range)
  end
end
