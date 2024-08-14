class FollowupService
  def self.create_followup(followupable, creator, note)
    followup = followupable.followups.new(
      creator: creator,
      status: :requested,
      note: note,
      followupable: followupable,
    )

    if followup.save
      maintain_backward_compatibility(followupable, followup)
      send_followup_notification(followup, creator)
    end

    followup
  end

  private_class_method

  # TODO: polymorph can remove this once all new rights are working and in production
  def self.maintain_backward_compatibility(followupable, followup)
    # Only update the old column if followupable is a CaseContact
    if followupable.is_a?(CaseContact)
      followup.update_column(:case_contact_id, followupable.id)
    end
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
