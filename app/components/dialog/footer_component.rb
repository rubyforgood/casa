# frozen_string_literal: true

# The footer region of a design-system dialog: a divided action row. Actions are
# right-aligned by default (`:end`); use `:center` for a single-action status modal.
# Build the actions with the `button_classes` helper.
class Dialog::FooterComponent < ViewComponent::Base
  def initialize(align: :end)
    @align = align
  end

  def footer_classes
    justify = (@align == :center) ? "justify-center" : "justify-end"
    "flex items-center #{justify} gap-2 border-t border-slate-100 px-5 py-4"
  end
end
