class EmancipationChecklistDownloadHtml
  def initialize(current_case, emancipation_form_data)
    @current_case = current_case
    @emancipation_form_data = emancipation_form_data
  end

  def call
    html_body = ApplicationController.render(
      template: "emancipations/download",
      layout: false,
      assigns: {
        current_case: @current_case,
        emancipation_form_data: @emancipation_form_data
      }
    ).squish

    html_body = html_body.gsub("<!-- BEGIN app/views/emancipations/download.html.erb -->", "")
    html_body = html_body.gsub("<!-- END app/views/emancipations/download.html.erb -->", "")

    html_body.gsub("> <", "><")
  end
end
