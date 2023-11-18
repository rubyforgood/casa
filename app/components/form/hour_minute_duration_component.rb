# frozen_string_literal: true

class Form::HourMinuteDurationComponent < ViewComponent::Base
  def initialize(form:, hour_value:, minute_value:)
    @form = form
    @hour_value = hour_value
    @minute_value = minute_value
  end

end
