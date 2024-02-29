# frozen_string_literal: true

class KebabMenuComponent < ViewComponent::Base
  renders_one :menu_content

  def initialize(menu_title: "Menu")
    @menu_title = menu_title
  end
end
