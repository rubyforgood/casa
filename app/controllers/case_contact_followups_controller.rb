class CaseContactFollowupsController < ApplicationController
  def create
    case_contact = CaseContact.find(params[:contact_id])
    case_contact.update(followup_created_at: Time.now)
  end
end
