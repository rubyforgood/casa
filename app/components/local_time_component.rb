# frozen_string_literal: true

class LocalTimeComponent < ViewComponent::Base
  include ActionController::Cookies
  attr_reader :format, :unix_timestamp

  def initialize(format:, unix_timestamp:)
    @format = format
    @unix_timestamp = unix_timestamp
  end

  def local_time
    time = Time.at(unix_timestamp).in_time_zone(@time_zone)
    time.strftime(@format)
  end

  private

  def before_render
    browser_tz = ActiveSupport::TimeZone.find_tzinfo(cookies[:browser_time_zone])
    ActiveSupport::TimeZone.all.find { |zone| zone.tzinfo == browser_tz } || Time.zone
  rescue TZInfo::UnknownTimezone, TZInfo::InvalidTimezoneIdentifier
    @time_zone = Time.zone
  end
end
