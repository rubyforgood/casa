class EmancipationChecklistsController < ApplicationController
  include DateHelper
  before_action :require_organization!
  after_action :verify_authorized

  def index
    authorize :application, :see_emancipation_checklist?
    org_cases = current_user.casa_org.casa_cases.includes(:assigned_volunteers)
    @casa_transitioning_cases = policy_scope(org_cases).is_transitioned.includes([:hearing_type, :judge])

    if @casa_transitioning_cases.count == 1
      redirect_to casa_case_emancipation_path(@casa_transitioning_cases[0])
    end
  end
end
