# frozen_string_literal: true

class LocalTimeComponent < ViewComponent::Base
  attr_reader :format, :unix_timestamp, :time_zone

  def initialize(format:, unix_timestamp:, time_zone:)
    @format = format
    @time_zone = time_zone
    @unix_timestamp = unix_timestamp
  end

  def local_time
    time = Time.at(unix_timestamp).in_time_zone(@time_zone)
    time.strftime(@format)
  end

  def specific_time
    Time.at(unix_timestamp).in_time_zone(@time_zone).strftime("%b %d, %Y, %l:%M %p %Z")
  end
end
