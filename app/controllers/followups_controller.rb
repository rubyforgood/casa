class FollowupsController < ApplicationController
  after_action :verify_authorized

  ALLOWED_FOLLOWUPABLE_TYPES = ['CaseContact'].freeze # TODO: move to enum

  def create
    authorize Followup
    followupable = find_followupable
    note = simple_followup_params[:note]
    FollowupService.create_followup(followupable, current_user, note)

    redirect_to casa_case_path(followupable.casa_case)
  end

  def resolve
    @followup = Followup.find(params[:id])
    @casa_case = @followup.associated_casa_case

    authorize @followup, :resolve?

    @followup.resolved!
    send_followup_resolved_notification

    redirect_to casa_case_path(@casa_case)
  end

  private

  def simple_followup_params
    params.permit(:note, :followupable_id, :followupable_type)
  end

  def find_followupable
    followupable_type = params[:followupable_type]
    followupable_id = params[:followupable_id]

    # Validate the followupable_type against the whitelist
    if followupable_type.in?(ALLOWED_FOLLOWUPABLE_TYPES)
      followupable_class = followupable_type.constantize
      return followupable_class.find_by(id: followupable_id)
    else
      Rails.logger.warn("Attempt to access an unauthorized followupable type: #{followupable_type}")
      nil
    end
  end

  # TODO: move this to FollowupService
  def send_followup_resolved_notification
    return if current_user == @followup.creator
    FollowupResolvedNotifier
      .with(followup: @followup, created_by: current_user)
      .deliver(@followup.creator)
  end
end
