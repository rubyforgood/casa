# frozen_string_literal: true

class TruncatedTextComponent < ViewComponent::Base
  def initialize(text = nil, render_check: true)
    @text = text
    @render_check = render_check
  end

  def text_content
    return content if content.present?

    simple_format(@text)
  end

  def render?
    @render_check && (@text.present? || content.present?)
  end
end
