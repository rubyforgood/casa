# frozen_string_literal: true

class SupervisorsController < ApplicationController
  # Uses authenticate_user to redirect if no user is signed in
  # and must_be_admin_or_supervisor to check user's role is appropriate
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor
  before_action :must_be_admin, only: [:new, :create]
  before_action :available_volunteers, only: [:edit, :update]
  before_action :set_supervisor, only: [:edit, :update]

  def index
    @supervisors = policy_scope(current_organization.supervisors)
  end

  def new
    @supervisor = Supervisor.new
  end

  def create
    @supervisor = Supervisor.new(supervisor_params.merge(supervisor_values))

    if @supervisor.save
      @supervisor.invite!
      redirect_to edit_supervisor_path(@supervisor)
    else
      render new_supervisor_path
    end
  end

  def edit
    redirect_to root_url unless can_view_update_page?
  end

  def update
    if can_update_fields?
      if @supervisor.update(update_supervisor_params)
        redirect_to edit_supervisor_path(@supervisor), notice: "Supervisor was successfully updated."
      else
        render :edit
      end
    else
      redirect_to root_url
    end
  end

  private

  def set_supervisor
    @supervisor = Supervisor.find(params[:id])
  end

  def available_volunteers
    @available_volunteers = Volunteer.with_no_supervisor(current_user.casa_org)
  end

  def supervisor_values
    {password: SecureRandom.hex(10), casa_org_id: current_user.casa_org_id}
  end

  def supervisor_params
    params.require(:supervisor).permit(:display_name, :email, :active, volunteer_ids: [], supervisor_volunteer_ids: [])
  end

  def can_view_update_page?
    # supervisor must be able to view edit supervisor page so they can change volunteer assignments
    current_user.supervisor? || current_user.casa_admin?
  end

  def can_update_fields?
    current_user == @supervisor || current_user.casa_admin?
  end

  def update_supervisor_params
    return SupervisorParameters.new(params).without_type if current_user.casa_admin?

    SupervisorParameters.new(params).without_type.without_active
  end
end
