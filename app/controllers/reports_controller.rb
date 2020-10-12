class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize :application, :see_reports_page?
  end
end
