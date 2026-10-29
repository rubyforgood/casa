# Sign-in and password forms are often left open long enough that the session
# (and its CSRF token) changes underneath them, e.g. the user signed in or out in
# another tab. Send them back to the form with a message instead of a 422 page.
module RecoversFromStaleForm
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::InvalidAuthenticityToken, with: :redirect_to_fresh_form
  end

  private

  def redirect_to_fresh_form
    Rails.logger.info("Stale CSRF token on #{controller_path}##{action_name}; redirecting to a fresh form")
    redirect_back_or_to new_session_path(resource_name),
      alert: "Your page expired. Please try again."
  end
end
