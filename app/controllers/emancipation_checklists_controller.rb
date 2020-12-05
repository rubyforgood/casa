class EmancipationChecklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_organization!

  def index
    authorize :application, :see_emancipation_checklist?
    org_cases = current_user.casa_org.casa_cases.includes(:assigned_volunteers)
    @casa_transitioning_cases = policy_scope(org_cases).where(transition_aged_youth: true).includes([:hearing_type, :judge])

    if @casa_transitioning_cases.count == 1
      redirect_to casa_case_emancipation_path(@casa_transitioning_cases[0])
    end
  end
end
