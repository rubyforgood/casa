# frozen_string_literal: true

class Form::StepNavigationComponent < ViewComponent::Base
  def initialize(nav_back: nil, nav_next: nil)
    @nav_back = nav_back
    @nav_next = nav_next
  end
end
