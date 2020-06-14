class CasaCaseDecorator < Draper::Decorator
  delegate_all

  def transition_aged_youth_icon
    object.transition_aged_youth ? "Yes 🐛🦋" : "No"
  end
end
