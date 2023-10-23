# frozen_string_literal: true

class Sidebar::LinkComponent < ViewComponent::Base
  include SidebarHelper

  # @param title [String] the title/label for the link
  # @param path [String] the path to navigate to
  # @param icon [String] the lni icon, pass just the name of the icon (ie. for lni-star --> icon: "star")
  # @param nav_item [Boolean] whether or not the link should have the nav-item class
  # @param render_check [Boolean] whether or not to display the link
  def initialize(title:, path:, icon: nil, nav_item: true, render_check: true)
    @title = title
    @icon = icon
    @path = path
    @nav_item = nav_item
    @render_check = render_check
  end

  # Must be moved to this method in order to use the SidebarHelper
  def before_render
    @class = @nav_item ? "nav-item #{active_class(@path)}" : ""
  end

  # @return [Boolean]
  def render?
    @render_check
  end
end
