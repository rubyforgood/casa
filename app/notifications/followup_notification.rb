# To deliver this notification:
#
# FollowupNotification.with(followup: @followup).deliver_later(current_user)
# FollowupNotification.with(followup: @followup).deliver(current_user)

class FollowupNotification < Noticed::Base
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
  def title
    t(".title")
  end

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

  def created_by_name
    if params.key?(:created_by)
      params[:created_by][:display_name]
    else # keep backward compatibility with older notifications
      params[:created_by_name]
    end
  end
end
