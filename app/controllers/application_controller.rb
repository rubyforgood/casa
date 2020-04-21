class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  before_action :set_paper_trail_whodunnit
end
