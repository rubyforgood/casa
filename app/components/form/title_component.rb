# frozen_string_literal: true

class Form::TitleComponent < ViewComponent::Base
  def initialize(title:, subtitle:, step: nil, total_steps: nil, notes: nil, autosave: false, navigable: false, nav_back: nil, nav_next: nil)
    @title = title
    @subtitle = subtitle
    @notes = notes
    @autosave = autosave
    @navigable = navigable
    # @nav_back = nav_back if navigable
    # @nav_next = nav_next if navigable
    @nav_back = nav_back
    @nav_next = nav_next

    if step && total_steps
      @steps_in_text = "Step #{step} of #{total_steps}"
      @progress = (step.to_d / total_steps.to_d) * 100
    end
  end
end
