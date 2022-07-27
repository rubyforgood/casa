module SidebarHelper
  def menu_item(label:, path:, visible: true)
    link_to label, path, class: "list-group-item #{active_class(path)}" if visible
  end

  def active_class(link_path)
    url_route_sections = link_path.split("/")
    url_route_sections.delete("all_casa_admins")
    controller_name = url_route_sections.second
    current_page?({controller: controller_name, action: action_name}) ? "active" : ""
  rescue ActionController::UrlGenerationError
    ""
  end

  def cases_index_title
    return "My Cases" if current_user.volunteer?

    "Cases"
  end

  def inbox_label
    unread_count = current_user.notifications.unread.count
    return "Inbox" if unread_count == 0
    "Inbox <span class='badge badge-danger'>#{unread_count}</span>".html_safe
  end
end
