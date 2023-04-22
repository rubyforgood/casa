class PlacementDecorator < Draper::Decorator
  delegate_all

  def formatted_date
    I18n.l(object.placement_started_at, format: :full, default: nil)
  end

  def placement_info
    ["Started At:  #{formatted_date}", "Placement Type: #{placement_type&.name}"].compact.join(" - ")
  end
end
