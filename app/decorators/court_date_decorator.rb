class CourtDateDecorator < Draper::Decorator
  delegate_all

  def formatted_date
    I18n.l(object.date, format: :full, default: nil)
  end

  def court_date_info
    [formatted_date, hearing_type&.name].compact.join(" - ")
  end
end
