module UiHelper
  def return_to_dashboard_button
    link_to "Return to Dashboard", root_path, {class: "btn btn-info pull-right"}
  end
end
