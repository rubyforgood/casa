module ApplicationHelper
  def body_class
    qualified_controller_name = controller.controller_path.tr("/", "-")
    "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"
  end

  def logged_in?
    user_signed_in? || all_casa_admin_signed_in?
  end

  def not_logged_in?
    !logged_in?
  end

  def page_header
    return default_page_header unless user_signed_in?

    current_organization.display_name
  end

  def default_page_header
    "CASA / Volunteer Tracking"
  end

  def session_signout_link
    if user_signed_in?
      destroy_user_session_path
    elsif all_casa_admin_signed_in?
      destroy_all_casa_admin_session_path
    end
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

  def og_tag(type, options = {})
    tag.meta(property: "og:#{type}", **options)
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
