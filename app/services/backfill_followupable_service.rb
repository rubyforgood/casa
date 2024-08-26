class BackfillFollowupableService
  def fill_followup_id_and_type
    Followup.find_each(batch_size: 500) do |followup|
      followup.update_columns(
        followupable_id: followup.case_contact_id,
        followupable_type: "CaseContact"
      )
    rescue => e
      Bugsnag.notify(e) do |event|
        event.add_metadata(:followup, {
          followup_id: followup.id,
          case_contact_id: followup.case_contact_id
        })
      end
      Rails.logger.error "Failed to update Followup ##{followup.id}: #{e.message}"
    end
  end
end
