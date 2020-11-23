class VolunteersController < ApplicationController
  # Uses authenticate_user to redirect if no user is signed in
  # and must_be_admin_or_supervisor to check user's role is appropriate
  before_action :authenticate_user!, :must_be_admin_or_supervisor
  before_action :set_volunteer, except: [:index, :new, :create]

  def index
    # Return all active/inactive volunteers, inactive will be filtered by default
    @volunteers = policy_scope(
      current_organization.volunteers.includes(:versions, :supervisor, :supervisor_volunteer, :casa_cases, case_assignments: [:casa_case]).references(:supervisor, :casa_cases)
    ).decorate
  end

  def new
    authorize :volunteer
    @volunteer = Volunteer.new
  end

  def create
    @volunteer = Volunteer.new(create_volunteer_params)

    if @volunteer.save
      @volunteer.invite!
      redirect_to volunteers_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @volunteer.update(update_volunteer_params)
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was successfully updated."
    else
      render :edit
    end
  end

  def activate
    if @volunteer.activate
      VolunteerMailer.account_setup(@volunteer).deliver

      if (params[:redirect_to_path] == "casa_case") && (casa_case = CasaCase.find(params[:casa_case_id]))
        redirect_to edit_casa_case_path(casa_case), notice: "Volunteer was activated."
      else
        redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was activated."
      end
    else
      render :edit
    end
  end

  def deactivate
    if @volunteer.deactivate
      VolunteerMailer.deactivation(@volunteer).deliver

      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was deactivated."
    else
      render :edit
    end
  end

  private

  def set_volunteer
    # @volunteer = authorize User.find(params[:id]) # TODO fix this
    @volunteer = Volunteer.find(params[:id])
  end

  def generate_devise_password
    Devise.friendly_token.first(8)
  end

  def create_volunteer_params
    VolunteerParameters
      .new(params)
      .with_password(generate_devise_password)
      .without_active
  end

  def update_volunteer_params
    VolunteerParameters
      .new(params)
      .without_active
  end
end
