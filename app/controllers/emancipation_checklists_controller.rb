class EmancipationChecklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_organization!

  def index
    authorize :application, :see_emancipation_checklist?
    org_cases = current_user.casa_org.casa_cases.includes(:assigned_volunteers)
    @casa_cases = policy_scope(org_cases).includes([:hearing_type, :judge])

    if @casa_cases.count == 1
      puts '################################'
      puts @casa_cases.count
      redirect_to casa_case_emancipation_path(@casa_cases[0])
    end
  end
end
