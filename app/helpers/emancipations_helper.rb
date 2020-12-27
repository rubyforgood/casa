module EmancipationsHelper
  def emancipation_select_option_selected(casa_case, emancipation_option)
    casa_case.emancipation_options.include?(emancipation_option) ? "selected" : nil
  end

  def emancipation_checkbox_option_checked(casa_case, emancipation_option)
    casa_case.emancipation_options.include?(emancipation_option) ? "checked" : nil
  end
end
