class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor

  def index
  end
end
