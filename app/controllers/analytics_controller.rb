class AnalyticsController < ApplicationController
  after_action :verify_authorized
  skip_after_action :verify_policy_scoped # aggregates are org-scoped inside MetricsReport, not via a policy_scope

  def index
    authorize :analytics, :index?
    @active_nav = "analytics"
    @range = MetricsReport.clamp_range(params[:range])
    report = MetricsReport.new(casa_org: current_organization)
    @case_contacts = report.monthly_case_contacts(@range)
    @active_users = report.monthly_active_users(@range)
    @contact_heatmap = report.contact_creation_heatmap(@range)
    render layout: "casa_app"
  end
end
