module VolunteerHelper
  def volunteer_badge(casa_case, current_user)
    return '' if current_user.volunteer?

    badge_content = if casa_case.assigned_volunteers.present?
                      casa_case.assigned_volunteers.map(&:display_name).join(", ")
                    else
                      'Unassigned'
                    end

    content_tag(:span, badge_content, class: 'badge badge-pill light-bg text-black fs-6 fw-medium')
  end
end