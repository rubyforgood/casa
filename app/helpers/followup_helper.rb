module FollowupHelper
  def followup_icon(creator)
    return "fa-exclamation-circle text-warning" if creator.volunteer?
    "fa-exclamation-triangle text-danger"
  end

  def render_followup_button(entity)
    button_tag(type: 'button',
               class: 'followup-button main-btn btn-sm primary-btn-outline btn-hover',
               data: { followupable_type: entity.class.name, followupable_id: entity.id }) do
      concat content_tag(:i, "", class: "lni lni-calendar mr-5")
      concat "Make Reminder"
    end
  end
end
