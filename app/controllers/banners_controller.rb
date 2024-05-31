class BannersController < ApplicationController
  after_action :verify_authorized, except: %i[dismiss]
  before_action :set_banner, only: %i[edit update destroy dismiss]

  def index
    authorize :application, :admin_or_supervisor?

    @banners = current_organization.banners.includes(:user)
  end

  def new
    authorize :application, :admin_or_supervisor?

    @banner = Banner.new
  end

  def edit
    authorize :application, :admin_or_supervisor?
  end

  def dismiss
    session[:dismissed_banner] = @banner.id
    render json: {status: :ok}
  end

  def create
    authorize :application, :admin_or_supervisor?

    @banner = current_organization.banners.build(banner_params)

    Banner.transaction do
      deactivate_alternate_active_banner
      @banner.save!
    end

    redirect_to banners_path
  rescue
    render :new
  end

  def update
    authorize :application, :admin_or_supervisor?

    Banner.transaction do
      deactivate_alternate_active_banner
      @banner.update!(banner_params)
    end

    redirect_to banners_path
  rescue
    render :edit
  end

  def destroy
    authorize :application, :admin_or_supervisor?

    @banner.destroy
    redirect_to banners_path
  end

  private

  def set_banner
    @banner = current_organization.banners.find(params[:id])
  end

  def banner_params
    params.require(:banner).permit(:active, :content, :name, :expires_at).merge(user: current_user)
      .tap { |banner_params| set_expires_at_in_user_time_zone(banner_params) }
  end

  def set_expires_at_in_user_time_zone(banner_params)
    banner_params[:expires_at] = banner_params[:expires_at].in_time_zone(cookies[:browser_time_zone])
  end

  def deactivate_alternate_active_banner
    if banner_params[:active].to_i == 1
      alternate_active_banner = current_organization.banners.where(active: true).where.not(id: @banner.id).first
      alternate_active_banner&.update!(active: false)
    end
  end
end
