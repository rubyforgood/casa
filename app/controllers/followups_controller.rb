class FollowupsController < ApplicationController
  after_action :verify_authorized

  def create
    authorize Followup
    case_contact = CaseContact.find(params[:case_contact_id])

    followup = case_contact.followup
    if followup
      followup.resolved!
    else
      case_contact.create_followup(creator: current_user, status: :requested)
    end

    redirect_to casa_case_path(case_contact.casa_case)
  end
end
