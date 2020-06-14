class VolunteersController < ApplicationController
  # Uses authenticate_user to redirect if no user is signed in
  # and must_be_admin_or_supervisor to check user's role is appropriate
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor

  def new
    @volunteer = User.new(role: :volunteer)
  end

  def create
    @volunteer = User.new(create_volunteer_params)

    if @volunteer.save
      VolunteerMailer.account_setup(@volunteer).deliver
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @volunteer = User.find(params[:id])
    @volunteer_active = @volunteer.active_volunteer
  end

  def update
    @volunteer = User.find(params[:id])

    if @volunteer.update(update_volunteer_params)
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was successfully updated."
    else
      render :edit
    end
  end

  def deactivate
    @volunteer = User.find(params[:id])

    if @volunteer.update_attributes(role: "inactive")
      @volunteer.case_assignments.update_all(is_active: false)
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was deactivated."
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
