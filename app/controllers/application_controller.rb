class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Organizational

  protect_from_forgery
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_current_organization
  # after_action :verify_authorized, except: :index # TODO add this back and fix all tests
  # after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  rescue_from Organizational::UnknownOrganization, with: :not_authorized

  impersonates :user

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  def after_sign_out_path_for(resource_or_scope)
    session[:user_return_to] = nil
    if resource_or_scope == :all_casa_admin
      new_all_casa_admin_session_path
    else
      root_path
    end
  end

  private

  def store_user_location!
    # the current URL can be accessed from a session
    store_location_for(:user, request.fullpath)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def set_current_user
    RequestStore.store[:current_user] = current_user
  end

  def set_current_organization
    RequestStore.store[:current_organization] = current_organization
  end

  def not_authorized
    session[:user_return_to] = nil
    flash[:notice] = t("default", scope: "pundit")
    redirect_to(root_url)
  end
end
