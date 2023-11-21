# frozen_string_literal: true

class Form::HourMinuteDurationComponent < ViewComponent::Base
  def initialize(form:, hour_value:, minute_value:)
    @form = form

    if hour_value.is_a?(String)
      begin
        @hour_value = Integer(hour_value)

        if @hour_value < 0
          raise RangeError.new("Parameter hour_value must be positive")
        end
      rescue ArgumentError
        raise ArgumentError.new("Could not convert parameter hour_value to an integer")
      end
    elsif hour_value.nil? || hour_value.is_a?(Integer)
      @hour_value = hour_value
    else
      raise TypeError.new("Parameter hour_value must be an integer")
    end

    if minute_value.is_a?(String)
      begin
        @minute_value = Integer(minute_value)

        if @minute_value < 0
          raise RangeError.new("Parameter minute_value must be positive")
        end
      rescue ArgumentError
        raise ArgumentError.new("Could not convert parameter minute_value to an integer")
      end
    elsif minute_value.nil? || minute_value.is_a?(Integer)
      @minute_value = minute_value
    else
      raise TypeError.new("Parameter minute_value must be an integer")
    end
  end
end
