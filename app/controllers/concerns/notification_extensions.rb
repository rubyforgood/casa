module NotificationExtensions
  extend ActiveSupport::Concern

  def muted_display
    "bg-light text-muted" if read?
  end
end
