module SidebarHelper
  def menu_item(label:, path:, visible: true)
    link_to label, path, class: "list-group-item #{active_class(path)}" if visible
  end

   def active_class(link_path)
    controller_name = link_path.split("/").second
    is_active = current_page?(controller: controller_name, action: :index) ||
                current_page?(controller: controller_name, action: :new) ||
                current_page?(controller: controller_name, action: :edit)

    is_active ? "active" : ""

  rescue ActionController::UrlGenerationError
    ""
  end

  def cases_index_title
    return "My Cases" if current_user.volunteer?

    "Cases"
  end
end
