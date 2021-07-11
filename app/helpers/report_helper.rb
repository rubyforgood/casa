module ReportHelper
  def boolean_choices
    [[I18n.t(".common.both_text"), ""], [I18n.t(".common.yes_text"), true], [I18n.t(".common.no_text"), false]]
  end
end
