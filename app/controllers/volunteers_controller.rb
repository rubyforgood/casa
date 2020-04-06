class VolunteersController < ApplicationController
  before_action :authenticate_user!

  def index
    @case_contact = CaseContact.new
  end

  def new
    @volunteer = User.new(role: :volunteer)
  end

  def create
    email = create_params[:email]
    casa_org_id = create_params[:casa_org_id]
    # Create a new user with a dummy password
    create_user_with_dummy_password(email, casa_org_id)
    # Send password reset email
    redirect_to root_path
  end

  def edit
  end

  private

  def create_user_with_dummy_password(email, casa_org_id)
    generated_password = Devise.friendly_token.first(8)
    user = User.create!(email: email, password: generated_password, casa_org_id: casa_org_id)
  end

  def create_params
    params.require(:user).permit(:email, :casa_org_id)
  end

end




# RegistrationMailer.welcome(user, generated_password).deliver
