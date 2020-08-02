class VolunteersController < ApplicationController
  # Uses authenticate_user to redirect if no user is signed in
  # and must_be_admin_or_supervisor to check user's role is appropriate
  before_action :authenticate_user!, :must_be_admin_or_supervisor
  before_action :set_volunteer, except: [:new, :create]

  def new
    @volunteer = Volunteer.new
  end

  def create
    @volunteer = Volunteer.new(create_volunteer_params)

    if @volunteer.save
      VolunteerMailer.account_setup(@volunteer).deliver
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @volunteer_active = @volunteer.active_volunteer
    @available_casa_cases = CasaCase.all.select { |cc| cc.case_assignments.any?(&:is_active) }.sort_by(&:case_number)
  end

  def update
    if @volunteer.update(update_volunteer_params)
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was successfully updated."
    else
      render :edit
    end
  end

  def activate
    if @volunteer.update(active: true)
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was activated."
    else
      render :edit
    end
  end

  def deactivate
    if @volunteer.update(active: false)
      @volunteer.case_assignments.update_all(is_active: false)
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was deactivated."
    else
      render :edit
    end
  end

  private

  def set_volunteer
    # @volunteer = authorize User.find(params[:id]) # TODO fix this
    @volunteer = User.find(params[:id])
  end

  def generate_devise_password
    Devise.friendly_token.first(8)
  end

  def create_volunteer_params
    UserParameters
      .new(params, key=:volunteer)
      .with_password(generate_devise_password)
  end

  def update_volunteer_params
    UserParameters.new(params, :volunteer)
  end
end
