# Calculate values when using banner parameters
class BannerParameters < SimpleDelegator
  def initialize(params, user, timezone)
    new_params = params.require(:banner).permit(:active, :content, :name, :expires_at).merge(user: user)

    if params.dig(:banner, :expires_at)
      new_params[:expires_at] = convert_expires_at_with_user_time_zone(params, timezone)
    end

    super(new_params)
  end

  private

  # `expires_at` comes from the frontend without any timezone information, so we use `in_time_zone` to attach
  # timezone information to it before saving to the database. If we don't do this, the time will be stored at UTC
  # by default.
  def convert_expires_at_with_user_time_zone(params, timezone)
    params[:banner][:expires_at].in_time_zone(timezone)
  end

  def params
    __getobj__
  end
end
