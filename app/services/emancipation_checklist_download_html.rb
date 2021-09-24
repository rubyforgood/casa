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
      },
    ).squish
  end
end
