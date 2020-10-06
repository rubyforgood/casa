# frozen_string_literal: true
class CaseCourtReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @assigned_cases = current_user.casa_cases
  end
end
