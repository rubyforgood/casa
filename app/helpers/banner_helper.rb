module BannerHelper
  def conditionally_add_hidden_class(current_banner_is_active)
    unless current_banner_is_active && current_organization.has_alternate_active_banner?(@banner.id)
      "d-none"
    end
  end

  def banner_expiration_time_in_words(banner)
    if banner.expired?
      "Expired"
    elsif banner.expires_at
      "in #{distance_of_time_in_words(Time.now, banner.expires_at)}"
    else
      "No Expiration"
    end
  end
end
