# Calculate values when using banner parameters
class BannerParameters < SimpleDelegator
  def initialize(params, user, timezone)
    new_params = params.require(:banner).permit(:active, :content, :name, :expires_at).merge(user: user)

    if params.dig(:banner, :expires_at)
      new_params[:expires_at] = convert_expires_at_in_user_time_zone(params, timezone)
    end

    super(new_params)
  end

  private

  def convert_expires_at_in_user_time_zone(params, timezone)
    params[:banner][:expires_at].in_time_zone(timezone)
  end

  def params
    __getobj__
  end
end
