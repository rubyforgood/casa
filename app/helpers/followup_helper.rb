module FollowupHelper
  def followup_icon(creator)
    return "fa-exclamation-circle text-warning" if creator.volunteer?
    "fa-exclamation-triangle text-danger"
  end
end
