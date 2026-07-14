# frozen_string_literal: true

# The native-<dialog> shell for the design-system modal. Pairs with the `modal`
# Stimulus controller (`showModal()` gives a focus trap, Escape-to-close, and an
# inert background for free). Compose the inside from Dialog::Header / Dialog::Body
# / Dialog::Footer so the template cannot drift. This is the Tailwind replacement
# for the legacy Bootstrap Modal::* suite; do not restyle Bootstrap `.modal` markup.
class Dialog::GroupComponent < ViewComponent::Base
  renders_one :trigger

  SIZES = {sm: "max-w-sm", md: "max-w-md", lg: "max-w-lg"}.freeze

  # size:            panel max-width (:sm | :md | :lg)
  # label:           accessible name for the dialog (usually the title text)
  # id:              optional id on the <dialog> (e.g. a JS / test hook)
  # open_on_connect: auto-open on connect via the modal controller
  # controllers:     extra Stimulus controllers on the wrapper (e.g. "court-report")
  # data:            extra wrapper data attributes (e.g. local-storage-reset-key-value)
  def initialize(size: :md, label: nil, id: nil, open_on_connect: false, controllers: nil, data: {})
    @size = size
    @label = label
    @id = id
    @open_on_connect = open_on_connect
    @controllers = controllers
    @data = data
  end

  def wrapper_data
    merged = @data.merge(controller: ["modal", @controllers].compact.join(" ").strip)
    merged[:modal_open_on_connect_value] = true if @open_on_connect
    merged
  end

  def panel_classes
    "w-[calc(100vw-2rem)] #{SIZES.fetch(@size)} overflow-hidden rounded-2xl p-0 text-left shadow-xl backdrop:bg-slate-900/40"
  end
end
