class FollowupService
  def self.create_followup(case_contact, creator, note)
    followup = case_contact.followups.new(
      creator: creator,
      status: :requested,
      note: note
    )

    # TODO Dual writing logic (temporary) polymorph
    followup.followupable = case_contact

    if followup.save
      send_notification(followup, creator)
    end

    followup
  end

  private_class_method def self.send_notification(followup, creator)
    recipients = [followup.case_contact.creator, creator].compact.uniq(&:id)
    FollowupNotifier
      .with(followup: followup, created_by: creator)
      .deliver(recipients)
  end
end
