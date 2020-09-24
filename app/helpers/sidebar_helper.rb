module SidebarHelper
  def menu_item(label:, path:, visible: true)
    link_to label, path, class: "list-group-item #{active_class(path)}" if visible
  end

   def active_class(link_path)
    controller_name = link_path.split("/").second
    is_active = current_page?(controller: controller_name, action: :index) ||
                current_page?(controller: controller_name, action: :edit) ||
                current_page?(controller: controller_name, action: :show)

    is_active ? "active" : ""

  rescue ActionController::UrlGenerationError
    ""
  end
end
