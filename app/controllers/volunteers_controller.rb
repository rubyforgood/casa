class VolunteersController < ApplicationController
  before_action :must_be_admin

  def new
    @volunteer = User.new(role: :volunteer)
  end

  def create
    volunteer = User.new(volunteer_params)

    if volunteer.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @volunteer = User.find(params[:id])
  end

  private

  def generate_devise_password
    Devise.friendly_token.first(8)
  end

  def volunteer_params
    VolunteerParameters
      .new(params)
      .with_password(generate_devise_password)
      .with_role('volunteer')
  end
end
