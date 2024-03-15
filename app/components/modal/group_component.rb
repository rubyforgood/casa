# frozen_string_literal: true

class Modal::GroupComponent < ViewComponent::Base
  renders_one :header, Modal::HeaderComponent
  renders_one :body, Modal::BodyComponent
  renders_one :footer, Modal::FooterComponent

  def initialize(id:, klass: nil, render_check: true)
    @id = id
    @class = klass
    @render_check = render_check
  end

  def render?
    @render_check && (body.present? || header.present?)
  end
end
