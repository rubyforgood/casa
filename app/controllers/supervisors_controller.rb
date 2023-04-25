# frozen_string_literal: true

class SupervisorsController < ApplicationController
  include SmsBodyHelper

  before_action :available_volunteers, only: [:edit, :update, :index]
  before_action :set_supervisor, only: [:edit, :update, :activate, :deactivate, :resend_invitation, :change_to_admin]
  before_action :all_volunteers_ever_assigned, only: [:update]
  before_action :supervisor_has_unassigned_volunteers, only: [:edit]

  after_action :verify_authorized

  def index
    authorize Supervisor
    @supervisors = policy_scope(current_organization.supervisors)
    @show_all = params[:all]
    if @show_all == "true"
      @supervisors
    else
      @supervisors = @supervisors.active
      @show_all = false
    end
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
      # call short io api here
      raw_token = @supervisor.raw_invitation_token
      invitation_url = Rails.application.routes.url_helpers.accept_user_invitation_url(invitation_token: raw_token, host: request.base_url)
      hash_of_short_urls = @supervisor.phone_number.blank? ? {0 => nil, 1 => nil} : handle_short_url([invitation_url, request.base_url + "/users/edit"])
      body_msg = account_activation_msg("supervisor", hash_of_short_urls)
      sms_status = deliver_sms_to @supervisor, body_msg
      redirect_to edit_supervisor_path(@supervisor), notice: sms_acct_creation_notice("supervisor", sms_status)
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
    @supervisor.skip_reconfirmation!

    if @supervisor.update(update_supervisor_params)
      @supervisor.filter_old_emails!(@supervisor.email)
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

  def change_to_admin
    authorize @supervisor
    @supervisor.change_to_admin!

    redirect_to edit_casa_admin_path(@supervisor), notice: "Supervisor was changed to Admin."
  end

  def datatable
    authorize Supervisor
    supervisors = policy_scope(current_organization.supervisors)

    datatable = SupervisorDatatable.new(supervisors, params)

    render json: datatable
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
    params.require(:supervisor).permit(:display_name, :email, :old_emails, :phone_number, :active, volunteer_ids: [], supervisor_volunteer_ids: [])
  end

  def update_supervisor_params
    return SupervisorParameters.new(params).without_type if current_user.casa_admin?

    SupervisorParameters.new(params).without_type.without_active
  end
end
