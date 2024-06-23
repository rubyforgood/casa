# frozen_string_literal: true

class Form::SubmitButtonComponent < ViewComponent::Base
  def initialize(last_step:, current_step:)
    @last_step = last_step
    @current_step = current_step
  end

  def button_text
    return "Submit" if @last_step == @current_step
    "Save and Continue"
  end
end
