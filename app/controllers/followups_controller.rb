class CaseContacts::FollowupsController < ApplicationController
  after_action :verify_authorized

  def create
    authorize Followup
    followupable = find_followupable
    # case_contact = CaseContact.find(params[:case_contact_id])
    note = simple_followup_params[:note]
    FollowupService.create_followup(followupable, current_user, note)

    redirect_to casa_case_path(followupable.casa_case)
  end

  def resolve
    @followup = Followup.find(params[:id])
    @casa_case = @followup.casa_case
    authorize @followup
    authorize @casa_case

    @followup.resolved!
    create_notification

    redirect_to casa_case_path(@casa_case)
  end

  private

  def simple_followup_params
    params.permit(:note)
  end

  def find_followupable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

  def create_notification
    return if current_user == @followup.creator
    FollowupResolvedNotifier
      .with(followup: @followup, created_by: current_user)
      .deliver(@followup.creator)
  end

end
