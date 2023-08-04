class BannersController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :admin_or_supervisor?

    @banners = current_organization.banners.includes(:user)
  end

  def new
    authorize :application, :admin_or_supervisor?

    @banner = Banner.new
    @has_alternate_active_banner = current_organization.banners.where(active: true).where.not(id: @banner.id).exists?
  end

  def edit
    authorize :application, :admin_or_supervisor?

    @banner = current_organization.banners.find(params[:id])
    @has_alternate_active_banner = current_organization.banners.where(active: true).where.not(id: @banner.id).exists?
  end

  def create
    authorize :application, :admin_or_supervisor?

    @banner = current_organization.banners.build(banner_params)
    if @banner.save
      redirect_to banners_path
    else
      render :new
    end
  end

  def update
    authorize :application, :admin_or_supervisor?

    @banner = current_organization.banners.find(params[:id])
    if @banner.update(banner_params)
      redirect_to banners_path
    else
      render :edit
    end
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
end
