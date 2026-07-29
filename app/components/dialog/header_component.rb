# frozen_string_literal: true

# The header row of a design-system dialog: an optional status badge, the title,
# and a close button. Render it inside Dialog::GroupComponent (it may sit inside a
# form for form-driven modals).
class Dialog::HeaderComponent < ViewComponent::Base
  BADGE = {
    danger: "bg-rose-100 text-rose-600",
    success: "bg-emerald-50 text-emerald-600",
    info: "bg-brand-50 text-brand-600"
  }.freeze

  # title:    heading text
  # icon:     optional bi-* class for a 32px status badge
  # variant:  badge color when an icon is shown (:danger | :success | :info)
  # closable: render the close (X) button (default true)
  def initialize(title:, icon: nil, variant: :info, closable: true)
    @title = title
    @icon = icon
    @variant = variant
    @closable = closable
  end

  def badge_classes
    "grid h-8 w-8 shrink-0 place-items-center rounded-full #{BADGE.fetch(@variant, BADGE[:info])}"
  end
end
