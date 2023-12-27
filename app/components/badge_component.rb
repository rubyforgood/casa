class BadgeComponent < ViewComponent::Base
  attr_reader :text, :type, :rounded

  def initialize(text:, type:, rounded: false)
    @text = text
    @type = type.to_sym
    @rounded = rounded
  end

  def style
    badge_style = ["bg-#{type}"]
    dark_text_types = [:warning, :light]
    badge_style.push("text-dark") if dark_text_types.include?(type)
    badge_style.push("rounded-pill") if rounded
    badge_style.join(" ")
  end
end