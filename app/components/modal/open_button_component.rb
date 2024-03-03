# frozen_string_literal: true

class Modal::OpenButtonComponent < ViewComponent::Base
  def initialize(target:, text: nil, klass: nil, icon: nil, render_check: true)
    @target = target
    @text = text
    @icon = icon
    @render_check = render_check
    @class = klass
  end

  def open_button
    return content if content.present?

    @text
  end

  def render?
    @render_check && (@text.present? || content.present?)
  end
end
