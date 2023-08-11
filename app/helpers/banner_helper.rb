module BannerHelper
  def conditionally_add_hidden_class(current_banner_is_active)
    unless current_banner_is_active && @org_has_alternate_active_banner
      "d-none"
    end
  end
end
