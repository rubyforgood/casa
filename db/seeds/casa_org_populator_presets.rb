# Preset option sets for various sizes and for the Rails environments.
# These do not include `org_name`, which can be provided separately by the caller to override default name.
module CasaOrgPopulatorPresets
  module_function

  def minimal_dataset_options
    {
      case_count: 1,
      volunteer_count: 1,
      supervisor_count: 1,
      casa_admin_count: 1
    }
  end

  def small_dataset_options
    {
      case_count: 8,
      volunteer_count: 5,
      supervisor_count: 2,
      casa_admin_count: 1
    }
  end

  def medium_dataset_options
    {
      case_count: 75,
      volunteer_count: 50,
      supervisor_count: 4,
      casa_admin_count: 2
    }
  end

  def large_dataset_options
    {
      case_count: 160,
      volunteer_count: 100,
      supervisor_count: 10,
      casa_admin_count: 3
    }
  end

  def for_environment
    {
      "development" => CasaOrgPopulatorPresets.small_dataset_options,
      "qa" => CasaOrgPopulatorPresets.large_dataset_options,
      "staging" => CasaOrgPopulatorPresets.large_dataset_options,
      "test" => CasaOrgPopulatorPresets.small_dataset_options
    }[ENV["APP_ENVIRONMENT"] || Rails.env]
  end
end
