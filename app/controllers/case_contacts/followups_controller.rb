class CaseContacts::FollowupsController < ApplicationController
  after_action :verify_authorized

  def create
    authorize Followup
    case_contact = CaseContact.find(params[:case_contact_id])
    note = simple_followup_params[:note]
    FollowupService.create_followup(case_contact, current_user, note)

    redirect_to casa_case_path(case_contact.casa_case)
  end

  def resolve
    @followup = Followup.find(params[:id])
    authorize @followup

    @followup.resolved!
    create_notification

    redirect_to casa_case_path(@followup.case_contact.casa_case)
  end

  private

  def simple_followup_params
    params.permit(:note)
  end

  def create_notification
    return if current_user == @followup.creator
    FollowupResolvedNotifier
      .with(followup: @followup, created_by: current_user)
      .deliver(@followup.creator)
  end
end
