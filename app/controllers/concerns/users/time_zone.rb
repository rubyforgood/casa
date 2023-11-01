module Users
  module TimeZone
    extend ActiveSupport::Concern

    included do
      helper_method :browser_time_zone
    end

    def browser_time_zone
      browser_tz = ActiveSupport::TimeZone.find_tzinfo(cookies[:browser_time_zone])
      ActiveSupport::TimeZone.all.find { |zone| zone.tzinfo == browser_tz } || Time.zone
    rescue TZInfo::UnknownTimezone, TZInfo::InvalidTimezoneIdentifier
      Time.zone
    end
  end
end
