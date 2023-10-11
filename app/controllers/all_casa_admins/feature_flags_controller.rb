class AllCasaAdmins::FeatureFlagsController < AllCasaAdminsController

  def index
    @feature_flags = FeatureFlag.all
  end


  # update: toggle
  # feature is disabled, when clicked on, update it to enabled

  def update
    byebug
    @feature_flag = FeatureFlag.find(params[:id])
    @feature_flag.update(enabled: !@feature_flag.enabled)
  end


end
