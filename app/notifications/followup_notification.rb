# To deliver this notification:
#
# FollowupNotification.with(followup: @followup).deliver_later(current_user)
# FollowupNotification.with(followup: @followup).deliver(current_user)

class FollowupNotification < BaseNotification
  # Add your delivery methods
  #
  deliver_by :database
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  param :followup, :created_by

  # Define helper methods to make rendering easier.
  #
  def message
    note = params[:followup][:note]

    note.present? ? message_with_note(note) : message_without_note
  end

  def url
    edit_case_contact_path(params[:followup][:case_contact_id], notification_id: record.id)
  end

  private

  def message_with_note(note)
    [
      message_heading,
      t(".note", note: note),
      t(".more_info")
    ].join("\n")
  end

  def message_without_note
    [message_heading, t(".more_info")].join(" ")
  end

  def message_heading
    t(".message", created_by_name: created_by_name)
  end
end
