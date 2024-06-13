# frozen_string_literal: true

class TruncatedTextComponent < ViewComponent::Base
  attr_reader :text, :label
  def initialize(text = nil, label: nil)
    @text = text
    @label = label
  end
end
