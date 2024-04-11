# frozen_string_literal: true

class Form::MultipleSelectComponent < ViewComponent::Base
  def initialize(form:, name:, options:, selected_items:, option_sub_text: false)
    @form = form
    @name = name
    @options = options.to_json
    @selected_items = selected_items
    @option_sub_text = option_sub_text
  end
end
