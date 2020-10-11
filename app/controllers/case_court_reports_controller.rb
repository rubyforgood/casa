# frozen_string_literal: true

class CaseCourtReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @assigned_cases = CasaCase.actively_assigned_to(current_user)
  end
end
