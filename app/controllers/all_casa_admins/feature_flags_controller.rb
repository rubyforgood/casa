class AllCasaAdmins::FeatureFlagsController < AllCasaAdminsController

  def index
    @feature_flags = FeatureFlag.all.order(name: 'asc')
  end

  def update
    @feature_flag = FeatureFlag.find(params[:id])
    @feature_flag.update(enabled: !@feature_flag.enabled)
  end
end
