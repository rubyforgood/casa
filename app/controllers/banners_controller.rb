class BannersController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :admin_or_supervisor?

    @banners = current_organization.banners.includes(:user)
  end

  def new
    authorize :application, :admin_or_supervisor?

    @banner = Banner.new
    @org_has_alternate_active_banner = current_organization.banners.where(active: true).where.not(id: @banner.id).exists?
  end

  def edit
    authorize :application, :admin_or_supervisor?

    @banner = current_organization.banners.find(params[:id])
    @org_has_alternate_active_banner = current_organization.banners.where(active: true).where.not(id: @banner.id).exists?
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

    @banner = current_organization.banners.find(params[:id])
    
    Banner.transaction do
      deactivate_alternate_active_banner
      @banner.update!(banner_params)
    end

    redirect_to banners_path
  rescue
    render :new
  end

  def destroy
    authorize :application, :admin_or_supervisor?

    current_organization.banners.find(params[:id]).destroy
    redirect_to banners_path
  end

  private

  def banner_params
    params.require(:banner).permit(:active, :content, :name).merge(user: current_user)
  end

  def deactivate_alternate_active_banner
    if banner_params[:active].to_i == 1
      alternate_active_banner = current_organization.banners.where(active: true).where.not(id: @banner.id).first
      alternate_active_banner&.update!(active: false)
    end
  end
end
