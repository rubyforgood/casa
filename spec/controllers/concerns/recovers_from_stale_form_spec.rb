require "rails_helper"

RSpec.describe RecoversFromStaleForm, type: :request do
  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  let(:user) { create(:volunteer) }
  let(:all_casa_admin) { create(:all_casa_admin) }

  it "redirects user sign in back to the form with a message" do
    post user_session_path,
      params: {user: {email: user.email, password: "12345678"}, authenticity_token: "stale"},
      headers: {"HTTP_REFERER" => new_user_session_url}

    expect(response).to redirect_to(new_user_session_url)
    expect(flash[:alert]).to eq("Your page expired. Please try again.")
  end

  it "falls back to the sign in page when there is no referer" do
    post user_password_path, params: {user: {email: user.email}, authenticity_token: "stale"}

    expect(response).to redirect_to(new_user_session_path)
    expect(flash[:alert]).to eq("Your page expired. Please try again.")
  end

  it "redirects all casa admin sign in back to its own form" do
    post all_casa_admin_session_path,
      params: {all_casa_admin: {email: all_casa_admin.email, password: "12345678"}, authenticity_token: "stale"}

    expect(response).to redirect_to(new_all_casa_admin_session_path)
  end

  it "redirects all casa admin password reset back to its sign in form" do
    post all_casa_admin_password_path,
      params: {all_casa_admin: {email: all_casa_admin.email}, authenticity_token: "stale"}

    expect(response).to redirect_to(new_all_casa_admin_session_path)
  end
end
