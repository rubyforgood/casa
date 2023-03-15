class SessionTimeoutController < Devise::SessionsController
  prepend_before_action :skip_timeout, only: [:check_session_timeout, :render_timeout]

  def check_session_timeout
    response.headers["Etag"] = "" # clear etags to prevent caching
    render plain: ttl_to_timeout, status: :ok

    if ttl_to_timeout < 10750
      flash[:alert] = "Your session will expire in 2 minutes due to inactivity."
      # flash[:alert] = t("devise.failure.timeout", default: "Your session has timed out.")
    end
  end

  def render_timeout
    if current_user.present? && user_signed_in?
      reset_session
      sign_out(current_user)
    end

    flash[:alert] = t("devise.failure.timeout", default: "Your session has timed out.")
    redirect_to login_path
  end
  
  private
  
    def ttl_to_timeout
      return 0 if user_session.blank?
  
      Devise.timeout_in - (Time.now.utc - last_request_time).to_i
    end
  
    def last_request_time
      user_session["last_request_at"].presence || 0
    end
    
    def skip_timeout
      request.env["devise.skip_trackable"] = true
    end
  end
