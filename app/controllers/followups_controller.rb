class FollowupsController < ApplicationController
  def create
    p params
    case_contact = CaseContact.find(params[:contact_id])
    followup = case_contact.followup
    if followup
      followup.update(status: :resolved)
    else
      case_contact.create_followup(creator: current_user, status: :requested)
    end

    redirect_to casa_case_path(case_contact.casa_case)
  end
end
