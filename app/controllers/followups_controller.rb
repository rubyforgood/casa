class FollowupsController < ApplicationController
  def create
    case_contact = CaseContact.find_by(id: params[:case_contact_id])

    if case_contact
      followup = case_contact.followup
      if followup
        followup.resolved!
      else
        case_contact.create_followup(creator: current_user, status: :requested)
      end
      redirect_to casa_case_path(case_contact.casa_case)
    else
      redirect_to casa_cases_path
    end
  end
end
