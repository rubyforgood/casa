class CasaAdminsController < ApplicationController
  include SmsBodyHelper

  before_action :set_admin, except: [:index, :new, :create]
  before_action :require_organization!
  after_action :verify_authorized

  def index
    authorize CasaAdmin
    @admins = policy_scope(current_organization.casa_admins)
  end

  def edit
    authorize @casa_admin
  end

  def update
    authorize @casa_admin
    if @casa_admin.update(update_casa_admin_params)
      notice = check_unconfirmed_email_notice(@casa_admin)

      @casa_admin.filter_old_emails!(@casa_admin.email)
      respond_to do |format|
        format.html { redirect_to edit_casa_admin_path(@casa_admin), notice: notice }
        format.json { render json: @casa_admin, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_admin.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def new
    authorize CasaAdmin
    @casa_admin = CasaAdmin.new
  end

  def create
    service = ::CreateCasaAdminService.new(current_organization, params, current_user)
    @casa_admin = service.build
    authorize @casa_admin
    sms_status = "blank"

    begin
      casa_admin = service.create!
      if !casa_admin.phone_number.blank?
        raw_token = casa_admin.raw_invitation_token
        base_domain = request.base_url + "/users/edit"
        invitation_url = Rails.application.routes.url_helpers.accept_user_invitation_url(invitation_token: raw_token, host: request.base_url)
        hash_of_short_urls = handle_short_url([invitation_url, base_domain])
        body_msg = account_activation_msg("admin", hash_of_short_urls)
        sms_status = deliver_sms_to casa_admin, body_msg
      end
      respond_to do |format|
        format.html { redirect_to casa_admins_path, notice: sms_acct_creation_notice("admin", sms_status) }
        format.json { render json: @casa_admin, status: :created }
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html { render :new }
        format.json { render json: service.casa_admin.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def activate
    authorize @casa_admin

    if @casa_admin.activate
      CasaAdminMailer.account_setup(@casa_admin).deliver

      respond_to do |format|
        format.html do
          redirect_to edit_casa_admin_path(@casa_admin),
            notice: "Admin was activated. They have been sent an email."
        end

        format.json { render json: @casa_admin, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_admin.errors.full_messages, status: :unprocessable_entity }
      end
    end
  rescue Errno::ECONNREFUSED => error
    redirect_to_casa_admin_edition_page(error)
  end

  def deactivate
    authorize @casa_admin
    if @casa_admin.deactivate
      CasaAdminMailer.deactivation(@casa_admin).deliver

      respond_to do |format|
        format.html { redirect_to edit_casa_admin_path(@casa_admin), notice: "Admin was deactivated." }
        format.json { render json: @casa_admin, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_admin.errors.full_messages, status: :unprocessable_entity }
      end
    end
  rescue Errno::ECONNREFUSED => error
    redirect_to_casa_admin_edition_page(error)
  end

  def resend_invitation
    authorize @casa_admin
    @casa_admin.invite!

    redirect_to edit_casa_admin_path(@casa_admin), notice: "Invitation sent"
  end

  def change_to_supervisor
    authorize @casa_admin
    @casa_admin.change_to_supervisor!

    redirect_to edit_supervisor_path(@casa_admin), notice: "Admin was changed to Supervisor."
  end

  private

  def redirect_to_casa_admin_edition_page(error)
    Bugsnag.notify(error)

    redirect_to edit_casa_admin_path(@casa_admin), alert: "Email not sent."
  end

  def set_admin
    @casa_admin = CasaAdmin.find(params[:id])
  end

  def update_casa_admin_params
    CasaAdminParameters.new(params).with_only(:email, :display_name, :phone_number, :date_of_birth, :monthly_learning_hours_report)
  end

  def learning_hours_checked?
    ActiveModel::Type::Boolean.new.cast(params[:monthly_learning_hours_report])
  end
end
