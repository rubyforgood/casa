module EmancipationsHelper
  def emancipation_select_option_selected(casa_case, emancipation_option_id)
    casa_case.contains_emancipation_option?(emancipation_option_id) ? "selected" : nil
  end

  def emancipation_checkbox_option_checked(casa_case, emancipation_option_id)
    casa_case.contains_emancipation_option?(emancipation_option_id) ? "checked" : nil
  end
end
