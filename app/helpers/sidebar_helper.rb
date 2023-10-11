module SidebarHelper
  def cases_index_title
    return "My Cases" if current_user.volunteer?

    "Cases"
  end

  def inbox_label
    unread_count = current_user.notifications.unread.count
    return "Inbox" if unread_count == 0
    "Inbox <span class='badge badge-danger'>#{unread_count}</span>".html_safe
  end

  def menu_item(label:, path:, visible: false)
    link_to label, path, class: "list-group-item #{active_class(path)}" if visible
  end

  def get_case_contact_link(casa_case)
    case_contacts_path(casa_case_id: casa_case.id)
  end

  private # private doesn't work in modules. It's here for semantic purposes

  def active_class(link_path)
    if request_path_active?(link_path)
      "active"
    else
      ""
    end
  rescue ActionController::UrlGenerationError
    ""
  end

  def request_path_active?(link_path)
    # The second check is needed because Sidebar menu item 'Emancipation
    # Checklist(s)' contains a redirect if any @casa_transitioning_cases are
    # found
    (request.path == link_path) ||
      (link_path == "/emancipation_checklists" && request.path.match("emancipation"))
  end
end
