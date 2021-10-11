class CourtDateDecorator < Draper::Decorator
  delegate_all

  def formatted_date
    I18n.l(object.date, format: :full, default: nil)
  end
end
