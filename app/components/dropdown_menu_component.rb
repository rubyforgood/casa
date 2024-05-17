# frozen_string_literal: true

class DropdownMenuComponent < ViewComponent::Base
  renders_one :icon

  def initialize(menu_title:, icon_name: nil, hide_label: false, render_check: true, klass: nil)
    @menu_title = menu_title
    @render_check = render_check
    @hide_label = hide_label
    @icon_name = icon_name
    @class = klass
  end

  def render_icon
    return icon if icon.present?

    content_tag(:i, nil, class: "lni mr-10 lni-#{@icon_name}")
  end

  def icon?
    icon.present? || @icon_name.present?
  end

  def render?
    @render_check && @menu_title.present? && content.present?
  end

  def button_label
    content_tag(:span, @menu_title, class: @hide_label ? "sr-only" : nil)
  end
end
