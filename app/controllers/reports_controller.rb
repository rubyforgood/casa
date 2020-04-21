require 'csv'

class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index; end

  def show
    respond_to do |format|
      format.csv do
        send_data CaseContactReport.to_csv,
                  filename: "case-contacts-report-#{Time.zone.now.to_i}.csv"
      end
    end
  end
end
