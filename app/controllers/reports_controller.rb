require 'csv'

class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index; end

  def show
    @case_contacts = CaseContact.all

    respond_to do |format|
      format.csv { send_data @case_contacts.to_csv, filename: "case-contacts-report-#{Time.zone.now.to_i}.csv" }
    end
  end
end
