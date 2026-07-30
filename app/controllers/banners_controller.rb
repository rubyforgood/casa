class BannersController < ApplicationController
  layout "casa_app"
  before_action -> { @active_nav = "settings" }, except: %i[dismiss]
  after_action :verify_authorized, except: %i[dismiss]
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does
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

    redirect_to banners_path, **banner_created_flash
  rescue
    render :new, status: :unprocessable_content
  end

  def update
    authorize :application, :admin_or_supervisor?

    Banner.transaction do
      deactivate_alternate_active_banner
      @banner.update!(banner_params)
    end

    redirect_to banners_path, **banner_created_flash(verb: "updated")
  rescue
    render :edit, status: :unprocessable_content
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
    BannerParameters.new(params, current_user, browser_time_zone)
  end

  def banner_created_flash(verb: "created")
    if @banner.active?
      {notice: "Banner #{verb} and is now showing at the top of every page."}
    else
      {alert: "Banner #{verb}, but it is not active, so no one will see it yet. Use Activate to show it."}
    end
  end

  def deactivate_alternate_active_banner
    if banner_params[:active].to_i == 1
      alternate_active_banner = current_organization.banners.where(active: true).where.not(id: @banner.id).first
      alternate_active_banner&.update!(active: false)
    end
  end
end
