class FollowupService
  def self.create_followup(followupable, creator, note)
    followup = followupable.followups.new(
      creator: creator,
      status: :requested,
      note: note,
      followupable: followupable,
    )

    if followup.save
      send_followup_notification(followup, creator)
    end

    followup
  end

  def self.resolve_followup(followup, user)
    followup.resolved!
    send_followup_resolved_notification(followup, user)
  end

  private_class_method

  def self.send_followup_resolved_notification(followup, user)
    return if user == followup.creator
    FollowupResolvedNotifier
      .with(followup: followup, created_by: user)
      .deliver(followup.creator)
  end

  def self.send_followup_notification(followup, creator)
    recipient = case followup.followupable
                when CaseContact
                  followup.followupable.creator
                else
                  Rails.logger.warn("Unsupported followupable type: #{followup.followupable_type}")
                end
    FollowupNotifier
      .with(followup: followup, created_by: creator)
      .deliver(recipient)
  end
end
