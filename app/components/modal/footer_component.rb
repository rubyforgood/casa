# frozen_string_literal: true

class Modal::FooterComponent < ViewComponent::Base
  def initialize(klass: nil, render_check: true)
    @render_check = render_check
    @class = klass
  end

  def render?
    @render_check && content.present?
  end
end
