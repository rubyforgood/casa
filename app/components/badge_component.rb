class BadgeComponent < ViewComponent::Base
  DARK_TEXT_TYPES = [:warning, :light]

  attr_reader :text, :type, :rounded

  def initialize(text:, type:, rounded: false)
    @text = text
    @type = type.to_sym
    @rounded = rounded
  end

  def style
    badge_style = ["bg-#{type}"]
    badge_style.push("text-dark") if DARK_TEXT_TYPES.include?(type)
    badge_style.push("rounded-pill") if rounded
    badge_style.join(" ")
  end
end