# frozen_string_literal: true

class SupervisorsController < ApplicationController
  before_action :available_volunteers, only: [:edit, :update, :index]
  before_action :set_supervisor, only: [:edit, :update, :activate, :deactivate, :resend_invitation]
  before_action :all_volunteers_ever_assigned, only: [:update]
  before_action :supervisor_has_unassigned_volunteers, only: [:edit]

  after_action :verify_authorized

  def index
    authorize Supervisor
    @supervisors = policy_scope(current_organization.supervisors)
  end

  def new
    authorize Supervisor
    @supervisor = Supervisor.new
  end

  def create
    authorize Supervisor
    @supervisor = Supervisor.new(supervisor_params.merge(supervisor_values))

    if @supervisor.save
      @supervisor.invite!(current_user)
      redirect_to edit_supervisor_path(@supervisor)
    else
      render new_supervisor_path
    end
  end

  def edit
    authorize @supervisor
    if params[:include_unassigned] == "true"
      all_volunteers_ever_assigned
    end
    @unassigned_volunteer_count ||= 0
  end

  def update
    authorize @supervisor
    if @supervisor.update(update_supervisor_params)
      redirect_to edit_supervisor_path(@supervisor), notice: "Supervisor was successfully updated."
    else
      render :edit
    end
  end

  def activate
    authorize @supervisor
    if @supervisor.activate
      SupervisorMailer.account_setup(@supervisor).deliver

      redirect_to edit_supervisor_path(@supervisor), notice: "Supervisor was activated. They have been sent an email."
    else
      render :edit, notice: "Supervisor could not be activated."
    end
  end

  def deactivate
    authorize @supervisor
    if @supervisor.deactivate
      redirect_to edit_supervisor_path(@supervisor), notice: "Supervisor was deactivated."
    else
      render :edit, notice: "Supervisor could not be deactivated."
    end
  end

  def resend_invitation
    authorize @supervisor
    @supervisor.invite!

    redirect_to edit_supervisor_path(@supervisor), notice: "Invitation sent"
  end

  private

  def set_supervisor
    @supervisor = Supervisor.find(params[:id])
  end

  def all_volunteers_ever_assigned
    @unassigned_volunteer_count = @supervisor.volunteers_ever_assigned.count - @supervisor.volunteers.count
    @all_volunteers_ever_assigned = @supervisor.volunteers_ever_assigned
  end

  def supervisor_has_unassigned_volunteers
    @supervisor_has_unassigned_volunteers = @supervisor.volunteers_ever_assigned.count > @supervisor.volunteers.count
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

  def update_supervisor_params
    return SupervisorParameters.new(params).without_type if current_user.casa_admin?

    SupervisorParameters.new(params).without_type.without_active
  end
end
