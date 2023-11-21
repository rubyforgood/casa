# frozen_string_literal: true

class Form::HourMinuteDurationComponent < ViewComponent::Base
  def initialize(form:, hour_value:, minute_value:)
    @form = form

    if hour_value.is_a?(String)
      begin
        @hour_value = Integer(hour_value)
      rescue ArgumentError
        raise ArgumentError.new("Could not convert parameter hour_value to an integer")
      end
    elsif !hour_value.is_a?(Integer)
      raise TypeError.new("Parameter hour_value must be an integer")
    else
      @hour_value = hour_value
    end

    if minute_value.is_a?(String)
      begin
        @minute_value = Integer(minute_value)
      rescue ArgumentError
        raise ArgumentError.new("Could not convert parameter minute_value to an integer")
      end
    elsif !minute_value.is_a?(Integer)
      raise TypeError.new("Parameter minute_value must be an integer")
    else
      @minute_value = minute_value
    end

    if @hour_value < 0
      raise RangeError.new("Parameter hour_value must be positive")
    end

    if @minute_value < 0
      raise RangeError.new("Parameter minute_value must be positive")
    end
  end
end
