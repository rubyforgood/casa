module ApplicationHelper
  def body_class
    qualified_controller_name = controller.controller_path.tr("/", "-")
    "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"
  end

  def casa_org
    casa_org_display_name = @casa_org.display_name
    user_signed_in? ? link_to(casa_org_display_name, root_path) : casa_org_display_name
  end

  def session_link
    if user_signed_in?
      link_to("Log out", destroy_user_session_path, class: "list-group-item")
    elsif all_casa_admin_signed_in?
      link_to("Log out", destroy_all_casa_admin_session_path, class: "list-group-item")
    else
      link_to("Log in", new_user_session_path, class: "list-group-item")
    end
  end

  def flash_class(level)
    case level
    when "notice" then "alert notice alert-info"
    when "success" then "alert success alert-success"
    when "error" then "alert error alert-danger"
    when "alert" then "alert alert-warning"
    end
  end

  def errors_for(object)
    if object.errors.any?
      content_tag(:div, class: "card border-danger") do
        concat(content_tag(:div, class: "card-header bg-danger text-white") {
          concat "#{pluralize(object.errors.count, "error")} prohibited this #{object.class.name.downcase} from being saved:"
        })
        concat(content_tag(:ul, class: "mb-0 list-group list-group-flush") {
          object.errors.full_messages.each do |msg|
            concat content_tag(:li, msg, class: "list-group-item")
          end
        })
      end
    end
  end
end
