module BannerHelper
  def conditionally_add_hidden_class(current_banner_is_active)
    unless current_banner_is_active && current_organization.has_alternate_active_banner?(@banner.id)
      "d-none"
    end
  end

  def active_banner
    @active_banner ||= current_organization.banners.active.first
  end

  def active_banner?
    active_banner.present?
  end

  def display_active_banner?
    active_banner? && cookies[dismiss_banner_cookie_name].nil?
  end

  def banner_cookie_name
    raise StandardError, "No active banner" unless active_banner?

    "banner_#{active_banner.id}"
  end

  def dismiss_banner_cookie_name
    "dismiss_#{banner_cookie_name}"
  end
end
