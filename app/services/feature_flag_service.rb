class FeatureFlagService
  SOME_FLAG = "some_flag"
  SHOW_ADDITIONAL_EXPENSES_FLAG = "show_additional_expenses"
  SHOW_OTHER_DUTIES_FLAG = "show_other_duties"

  def self.is_enabled?(feature_flag_name)
    FeatureFlag.find_by(name: feature_flag_name)&.enabled
  end

  def self.enable!(feature_flag_name)
    FeatureFlag.find_or_create_by(name: feature_flag_name).update!(enabled: true)
  end

  def self.disable!(feature_flag_name)
    FeatureFlag.find_or_create_by(name: feature_flag_name).update!(enabled: false)
  end
end
