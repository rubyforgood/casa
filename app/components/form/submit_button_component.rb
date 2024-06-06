# frozen_string_literal: true

class Form::SubmitButtonComponent < ViewComponent::Base
  def initialize(last_step:, current_step:)
    @text = submit_button_text(last_step:, current_step:)
  end

  def submit_button_text(last_step:, current_step:)
    return "Submit" if last_step == current_step
    "Save and Continue"
  end
end
