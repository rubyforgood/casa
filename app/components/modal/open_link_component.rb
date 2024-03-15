# frozen_string_literal: true

class Modal::OpenLinkComponent < ViewComponent::Base
  def initialize(target:, text: nil, icon: nil, klass: nil, render_check: true)
    @target = target
    @text = text
    @icon = icon
    @class = klass
    @render_check = render_check
  end

  def open_link
    return content if content.present?

    @text
  end

  def render?
    @render_check && (@text.present? || content.present?)
  end
end
