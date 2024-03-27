# frozen_string_literal: true

class Modal::BodyComponent < ViewComponent::Base
  def initialize(text: nil, klass: nil, render_check: true)
    @text = text
    @render_check = render_check
    @class = klass
  end

  def body_content
    return content if content.present?

    Array.wrap(@text).map do |text|
      content_tag :p, text
    end.join.html_safe
  end

  def render?
    @render_check && (@text.present? || content.present?)
  end
end
