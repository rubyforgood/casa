class ApplicationController < ActionController::Base
  include Pundit
  include Organizational

  protect_from_forgery
  before_action :set_paper_trail_whodunnit
  before_action :set_organization

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  rescue_from Organizational::UnknownOrganization, with: :not_authorized

  private

  def must_be_admin
    return if current_user&.casa_admin?

    flash[:notice] = "You do not have permission to view that page."
    redirect_to root_url
  end

  def must_be_admin_or_supervisor
    return if current_user&.casa_admin? || current_user&.supervisor?

    flash[:notice] = "You do not have permission to view that page."
    redirect_to root_url
  end

  def not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || root_url)
  end

  # Tmp probably until we get more multi-tenancy stuff in place
  def set_organization
    @casa_org = current_user ? current_user.casa_org : CasaOrg.first
  end
end
