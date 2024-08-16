class PlacementDecorator < Draper::Decorator
  delegate_all

  def formatted_date
    I18n.l(object.placement_started_at, format: :full, default: nil)
  end

  def placement_info
    ["Started At:  #{formatted_date}", "Placement Type: #{placement_type&.name}"].compact.join(" - ")
  end

  def placement_started_at
    I18n.l(placement.placement_started_at, format: :full, default: nil)
  end

  def created_at
    I18n.l(placement.created_at, format: :full, default: nil)
  end
end
