module EmancipationsHelper
  def emancipation_category_checkbox_checked(casa_case, emancipation_category)
    case_contains_category?(casa_case, emancipation_category) ? "checked" : nil
  end

  def emancipation_category_collapse_hidden(casa_case, emancipation_category)
    case_contains_category?(casa_case, emancipation_category) ? nil : "display: none;"
  end

  def emancipation_category_collapse_icon(casa_case, emancipation_category)
    case_contains_category?(casa_case, emancipation_category) ? "−" : "+"
  end

  def emancipation_option_checkbox_checked(casa_case, emancipation_option)
    casa_case.emancipation_options.include?(emancipation_option) ? "checked" : nil
  end

  def emancipation_category_checkbox_checked_download(casa_case, emancipation_category)
    case_contains_category?(casa_case, emancipation_category) ? "🗹" : "☐"
  end

  def emancipation_option_checkbox_checked_download(casa_case, emancipation_option)
    casa_case.emancipation_options.include?(emancipation_option) ? "🗹" : "☐"
  end

  def emancipation_option_radio_checked_download(casa_case, emancipation_option)
    casa_case.emancipation_options.include?(emancipation_option) ? "⦿" : "◯"
  end

  private

  def case_contains_category?(casa_case, emancipation_category)
    casa_case.emancipation_categories.include?(emancipation_category)
  end
end
