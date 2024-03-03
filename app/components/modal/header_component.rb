# frozen_string_literal: true

class Modal::HeaderComponent < ViewComponent::Base
  def initialize(id:, text: nil, icon: nil, klass: nil, render_check: true)
    @text = text
    @id = id
    @icon = icon
    @render_check = render_check
    @class = klass
  end

  def header_content
    return content if content.present?

    content_tag :h1, class: "modal-title fs-5", id: "#{@id}-label" do
      concat(content_tag(:i, nil, class: "lni mr-10 lni-#{@icon}")) if @icon.present?
      concat(@text)
    end
  end

  def render?
    @render_check && (@text.present? || content.present?)
  end
end
