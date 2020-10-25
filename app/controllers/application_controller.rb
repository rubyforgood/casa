class ApplicationController < ActionController::Base
  include Pundit
  include Organizational

  protect_from_forgery
  before_action :set_paper_trail_whodunnit

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  rescue_from Organizational::UnknownOrganization, with: :not_authorized

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :all_casa_admin
      new_all_casa_admin_session_path
    else
      root_path
    end
  end

  private

  def must_be_admin
    return if current_user&.casa_admin?

    flash[:notice] = t("default", scope: "pundit")
    redirect_to root_url
  end

  def must_be_admin_or_supervisor
    return if current_user&.casa_admin? || current_user&.supervisor?

    flash[:notice] = t("default", scope: "pundit")
    redirect_to root_url
  end

  def not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t("#{policy_name}.#{exception.query}", scope: "pundit", default: :default)
    redirect_to(request.referrer || root_url)
  end
end
