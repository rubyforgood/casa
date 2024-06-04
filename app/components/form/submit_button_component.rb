# frozen_string_literal: true

class Form::SubmitButtonComponent < ViewComponent::Base
  def initialize(last_step:, current_step:)
    if last_step == current_step
      @text = "Submit"
    else
      @text = "Save and continue"
    end
  end
end
