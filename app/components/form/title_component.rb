# frozen_string_literal: true

class Form::TitleComponent < ViewComponent::Base
  def initialize(title:, subtitle:, step: nil, total_steps: nil, notes: nil, autosave: false)
    @title = title
    @subtitle = subtitle
    @notes = notes
    @autosave = autosave

    if step && total_steps
      @steps_in_text = "Step #{step} of #{total_steps}"
      @progress = (step.to_d / total_steps.to_d) * 100
    end
  end
end
