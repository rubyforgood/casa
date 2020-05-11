class VolunteersController < ApplicationController
  # NOTE: I don't know what auth levels to use here, but am pretty certain it needs SOMETHING.
  before_action :authenticate_user!
  before_action :must_be_admin

  def new
    @volunteer = User.new(role: :volunteer)
  end

  def create
    volunteer = User.new(create_volunteer_params)

    if volunteer.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @volunteer = User.find(params[:id])
  end

  def update
    @volunteer = User.find(params[:id])

    if @volunteer.update(update_volunteer_params)
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was successfully updated."
    else
      render :edit
    end
  end

  private

  def generate_devise_password
    Devise.friendly_token.first(8)
  end

  def create_volunteer_params
    VolunteerParameters
      .new(params)
      .with_password(generate_devise_password)
      .with_role("volunteer")
  end

  def update_volunteer_params
    VolunteerParameters.new(params)
  end
end
