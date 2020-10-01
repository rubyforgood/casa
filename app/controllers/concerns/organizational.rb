module Organizational
  extend ActiveSupport::Concern

  class UnknownOrganization < StandardError
  end

  def require_organization!
    raise UnknownOrganization.new if current_organization.nil?
  end

  def current_organization
    @current_organization ||= current_user&.casa_org
  end

  def current_role
    @current_role ||= if user_signed_in?
      current_user.role
    elsif all_casa_admin_signed_in?
      current_all_casa_admin.role
    end
  end

  included do
    helper_method :current_organization
    helper_method :current_role
  end
end
