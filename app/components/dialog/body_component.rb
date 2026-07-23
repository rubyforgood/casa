# frozen_string_literal: true

# The body region of a design-system dialog. `centered` switches to the status
# layout (centered hero badge + title + text). Pass extra `classes` (e.g.
# "space-y-4") for form bodies with several stacked fields.
class Dialog::BodyComponent < ViewComponent::Base
  def initialize(centered: false, classes: nil)
    @centered = centered
    @classes = classes
  end

  def body_classes
    base = @centered ? "px-5 pt-6 pb-4 text-center" : "px-5 py-4"
    "#{base} #{@classes}".strip
  end
end
