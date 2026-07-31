# Design preview for the org announcement banner, browsable at /rails/view_components.
#
#   shipped        -- the REAL layouts/_casa_banner partial, so this page cannot drift from what ships
#   lead_variants  -- the "Name. content" typographic-lead options, NOT built, for review
#
# Previews render in the component_preview layout, which loads the same tailwind.css and JS bundle as
# the app, so what you see here is what the app renders.
class AnnouncementBannerPreview < ViewComponent::Preview
  layout "component_preview"

  def shipped
    render_with_template(locals: {banner: sample_banner})
  end

  def lead_variants
    render_with_template(locals: {banner: sample_banner})
  end

  private

  # Unsaved on purpose -- a preview should not write. id: 0 only exists so dismiss_banner_path can
  # build a URL; nothing here is meant to be clicked.
  def sample_banner
    banner = Banner.new(id: 0, name: "Quarterly reports")
    banner.content = "Quarterly court reports are due at month end. Please log any outstanding " \
                     "case contacts before then."
    banner
  end
end
