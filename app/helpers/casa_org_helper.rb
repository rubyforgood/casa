module CasaOrgHelper
  US_TIME_ZONES = [
    ["Eastern Time (America/New_York)", "America/New_York"],
    ["Central Time (America/Chicago)", "America/Chicago"],
    ["Mountain Time (America/Denver)", "America/Denver"],
    ["Pacific Time (America/Los_Angeles)", "America/Los_Angeles"],
    ["Alaska (America/Anchorage)", "America/Anchorage"],
    ["Hawaii (Pacific/Honolulu)", "Pacific/Honolulu"],
    ["Arizona (America/Phoenix)", "America/Phoenix"],
    ["Indiana - Indianapolis (America/Indiana/Indianapolis)", "America/Indiana/Indianapolis"],
    ["America/Adak", "America/Adak"],
    ["America/Boise", "America/Boise"],
    ["America/Detroit", "America/Detroit"],
    ["America/Indiana/Knox", "America/Indiana/Knox"],
    ["America/Indiana/Marengo", "America/Indiana/Marengo"],
    ["America/Indiana/Petersburg", "America/Indiana/Petersburg"],
    ["America/Indiana/Tell_City", "America/Indiana/Tell_City"],
    ["America/Indiana/Vevay", "America/Indiana/Vevay"],
    ["America/Indiana/Vincennes", "America/Indiana/Vincennes"],
    ["America/Indiana/Winamac", "America/Indiana/Winamac"],
    ["America/Juneau", "America/Juneau"],
    ["America/Kentucky/Louisville", "America/Kentucky/Louisville"],
    ["America/Kentucky/Monticello", "America/Kentucky/Monticello"],
    ["America/Menominee", "America/Menominee"],
    ["America/Metlakatla", "America/Metlakatla"],
    ["America/Nome", "America/Nome"],
    ["America/North_Dakota/Beulah", "America/North_Dakota/Beulah"],
    ["America/North_Dakota/Center", "America/North_Dakota/Center"],
    ["America/North_Dakota/New_Salem", "America/North_Dakota/New_Salem"],
    ["America/Sitka", "America/Sitka"],
    ["America/Yakutat", "America/Yakutat"]
  ].freeze

  GROUPED_TIME_ZONE_OPTIONS = begin
    us_identifiers = US_TIME_ZONES.map(&:last).to_set
    other_zones = (TZInfo::Timezone.all_identifiers.sort - us_identifiers.to_a).map { |id| [id, id] }

    [
      ["United States", US_TIME_ZONES],
      ["Other", other_zones]
    ].freeze
  end

  def grouped_time_zone_options
    GROUPED_TIME_ZONE_OPTIONS
  end
end
