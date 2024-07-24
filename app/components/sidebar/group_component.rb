# frozen_string_literal: true

class Sidebar::GroupComponent < ViewComponent::Base
  renders_many :links, Sidebar::LinkComponent

  # @param title [String] the title/label for the link
  # @param icon [String] the lni icon, pass just the name of the icon (ie. for lni-star --> icon: "star")
  # @param render_check [Boolean] whether or not to display the link
  def initialize(title:, icon:, render_check: true)
    @title = title
    @icon = icon
    @render_check = render_check
    @identifier = title.downcase.tr(" ", "-")
    @class = "#{@identifier} collapsed"
  end

  # If there are no links or all links fail their render_check, then don't render this group
  # @return [Boolean]
  def render?
    @render_check && !links.empty? && !links.select(&:render?).empty?
  end
end
