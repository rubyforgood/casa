class ApplicationController < ActionController::Base
  include Pundit
  include Organizational

  protect_from_forgery
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_current_organization
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

  protected

  def json_response(obj:, status:)
    return unless api?
    return render json: obj.errors.full_messages, status: status if status == :unprocessable_entity

    render json: obj, status: status
  end

  private

  def set_current_user
    RequestStore.store[:current_user] = current_user
  end

  def set_current_organization
    RequestStore.store[:current_organization] = current_organization
  end

  def not_authorized
    flash[:notice] = t("default", scope: "pundit")
    redirect_to(request.referrer || root_url)
  end

  def api?
    params[:api]&.to_boolean
  end
end
