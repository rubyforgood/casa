class BadgeComponent < ViewComponent::Base
  DARK_TEXT_TYPES = [:warning, :light]

  attr_reader :text

  def initialize(text:, type:, rounded: false, margin: true)
    @text = text
    @type = type.to_sym
    @rounded = rounded ? "rounded-pill" : nil
    @margin = margin ? "my-1" : nil
  end

  def style
    badge_style = ["bg-#{@type}", @rounded, @margin]
    badge_style.push("text-dark") if DARK_TEXT_TYPES.include?(@type)
    badge_style.compact.join(" ")
  end
end
