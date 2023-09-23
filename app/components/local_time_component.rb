# frozen_string_literal: true

class LocalTimeComponent < ViewComponent::Base
  include ActionController::Cookies
  attr_reader :format, :unix_timestamp

  def initialize(format:, unix_timestamp:)
    @format = format
    @unix_timestamp = unix_timestamp
  end

  def local_time
    # Time format should be passed as 12 or 24 only
    unless [12, 24].include?(format)
      raise ArgumentError, "Invalid time format argument"
    end

    time = Time.at(unix_timestamp).in_time_zone(@time_zone)
    time_format = format == 12 ? "%I:%M %p" : "%H:%M"
    formatted_date = time.strftime("%B %d, %Y")
    time_of_day = time.strftime(time_format)
    time_zone = time.zone
    formatted_date + " at " + time_of_day + " " + time_zone
  end

  private

  def before_render
    browser_tz = ActiveSupport::TimeZone.find_tzinfo(cookies[:browser_time_zone])
    ActiveSupport::TimeZone.all.find { |zone| zone.tzinfo == browser_tz } || Time.zone
  rescue TZInfo::UnknownTimezone, TZInfo::InvalidTimezoneIdentifier
    @time_zone = Time.zone
  end
end
