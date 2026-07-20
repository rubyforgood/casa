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
    @kpis = chapter_kpis(report)
    render layout: "casa_app"
  end

  private

  # Headline chapter numbers for the KPI cards. Reuses AdminDashboard for the org-scoped
  # "active volunteers" and "cases needing contact" (the app's canonical 14-day definition,
  # batched for org scale) and MetricsReport for the month-over-month contact delta.
  def chapter_kpis(report)
    dashboard = AdminDashboard.new(current_organization)
    this_month = report.contacts_this_month
    {
      contacts_this_month: this_month,
      contacts_delta: this_month - report.contacts_previous_month,
      active_volunteers: dashboard.stats[:volunteers],
      cases_needing_contact: dashboard.stats[:needs_contact],
      followup_days: AdminDashboard::FOLLOWUP_DAYS
    }
  end
end
