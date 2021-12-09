class CourtDateDecorator < Draper::Decorator
  delegate_all

  def formatted_date
    I18n.l(object.date, format: :full, default: nil)
  end

  def formatted_date_with_hearing_type_name
    formatted_date + " - " + hearing_type.name.titleize
  end
end
