# frozen_string_literal: true

class Form::StepNavigationComponent < ViewComponent::Base
  def initialize(nav_back: nil, nav_next: nil, submit_back: false, submit_next: false)
    @nav_back = nav_back
    @nav_next = nav_next
    @submit_back = submit_back
    @submit_next = submit_next
    @back_disabled = !@nav_back
    @next_disabled = !@nav_next
  end
end
