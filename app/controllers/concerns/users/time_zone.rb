module Users
  module TimeZone
    extend ActiveSupport::Concern

    included do
      helper_method :browser_time_zone
      helper_method :to_user_timezone
    end

    def browser_time_zone
      browser_tz = ActiveSupport::TimeZone.find_tzinfo(cookies[:browser_time_zone])
      ActiveSupport::TimeZone.all.find { |zone| zone.tzinfo == browser_tz } || Time.zone
    rescue TZInfo::UnknownTimezone, TZInfo::InvalidTimezoneIdentifier
      Time.zone
    end

    def to_user_timezone(time_date)
      return "" if time_date.nil? || (time_date.instance_of?(String) && time_date.empty?)

      time_zone = user_timezone
      return time_date.in_time_zone(time_zone) if time_date.respond_to?(:in_time_zone)

      time_date.to_time(time_zone)
    end

    def user_timezone
      (browser_time_zone && browser_time_zone != Time.zone) ? browser_time_zone : "Eastern Time (US & Canada)"
    end
  end
end
