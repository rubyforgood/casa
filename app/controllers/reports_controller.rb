class ReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :see_reports_page?
  end
end
