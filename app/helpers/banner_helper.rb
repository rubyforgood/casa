module BannerHelper
  def conditionally_add_hidden_class(current_banner_is_active)
    unless current_banner_is_active && current_organization.has_alternate_active_banner?(@banner.id)
      "d-none"
    end
  end
end
