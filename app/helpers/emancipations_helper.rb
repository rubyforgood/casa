module EmancipationsHelper
  def emancipation_option_select_selected?(casa_case, emancipation_option)
    casa_case.emancipation_options.include?(emancipation_option) ? "selected" : nil
  end

  def emancipation_category_checkbox_checked?(casa_case, emancipation_category)
    casa_case.emancipation_categories.include?(emancipation_category) ? "checked" : nil
  end

  def emancipation_option_checkbox_checked?(casa_case, emancipation_option)
    casa_case.emancipation_options.include?(emancipation_option) ? "checked" : nil
  end
end
