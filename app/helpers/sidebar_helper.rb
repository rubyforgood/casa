module SidebarHelper
  def menu_item(label:, path:, visible: true)
    link_to label, path, class: "list-group-item #{active_class(path)}" if visible
  end

   def active_class(link_path)
    current_page?(link_path) ? "active" : ""
  end
end
