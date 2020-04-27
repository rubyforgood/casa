class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  before_action :set_paper_trail_whodunnit

  def must_be_admin
    return if current_user&.casa_admin?

    flash[:notice] = 'You do not have permission to view that page.'
    redirect_to root_url
  end
end
