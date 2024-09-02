# frozen_string_literal: true

class Form::MultipleSelectComponent < ViewComponent::Base
  def initialize(form:, name:, options:, selected_items:, placeholder_term: "", render_option_subtext: false)
    @form = form
    @name = name
    @options = options.to_json
    @selected_items = selected_items
    @placeholder_term = placeholder_term
    @render_option_subtext = render_option_subtext
  end
end
