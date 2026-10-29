# Provides a means to present static pages that still use the site layout
class StaticController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_current_user
  skip_before_action :set_current_organization
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does

  layout false

  def index
    redirect_to dashboard_path_from_current_role if current_user
    @casa_logos = CasaOrg.with_logo
  end
end
