class CaseContacts::FollowupsController < ApplicationController
  after_action :verify_authorized

  def create
    authorize Followup
    case_contact = CaseContact.find(params[:case_contact_id])
    note = simple_followup_params[:note].presence
    FollowupService.create_followup(case_contact, current_user, note)

    respond_to do |format|
      format.html { redirect_back_or_to casa_case_path(case_contact.casa_case) }
      format.json { head :no_content }
    end
  end

  def resolve
    @followup = Followup.find(params[:id])
    authorize @followup

    @followup.resolved!
    create_notification

    respond_to do |format|
      format.html { redirect_back_or_to casa_case_path(@followup.case_contact.casa_case) }
      format.json { head :no_content }
    end
  end

  private

  def simple_followup_params
    params.permit(:note)
  end

  def create_notification
    recipients = [@followup.case_contact.creator, @followup.creator].compact.uniq(&:id).reject { |user| user.id == current_user.id }
    return if recipients.empty?
    FollowupResolvedNotifier
      .with(followup: @followup, created_by: current_user)
      .deliver(recipients)
  end
end
