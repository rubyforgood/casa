class PlacementDecorator < Draper::Decorator
  delegate_all

  def formatted_date
    I18n.l(object.placement_started_at, format: :full, default: nil)
  end

  def placement_info
    [formatted_date, placement_type&.name&.to_s].compact.join(" - ")
  end

  def placement_started_at
    I18n.l(placement.placement_started_at, format: :full, default: nil)
  end

  def created_at
    I18n.l(placement.created_at, format: :full, default: nil)
  end
end
