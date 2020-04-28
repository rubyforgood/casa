module ApplicationHelper
  def body_class
    qualified_controller_name = controller.controller_path.tr("/", "-")
    "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"
  end

  def page_header
    page_header_text = "CASA - Prince George's County, MD"
    user_signed_in? ? link_to(page_header_text, root_path) : page_header_text
  end

  def session_link
    if user_signed_in?
      link_to('Log out', destroy_user_session_path, class: 'btn btn-light')
    else
      link_to('Log in', new_user_session_path, class: 'btn btn-light')
    end
  end
end
