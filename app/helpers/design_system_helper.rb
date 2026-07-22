module DesignSystemHelper
  # Strip an honorific prefix (Mr./Mrs./...) from a name for display. Use at any
  # existing `.display_name` call site that shows a person's name.
  def formatted_name(name)
    NamePresentation.strip_honorific(name.to_s)
  end

  # A person's display name (honorific-free) with an email fallback. Prefer this for
  # new UI where you have the user object.
  def display_person(user)
    formatted_name(user.display_name.presence || user.email)
  end

  # Two-letter initials for avatars: first + last name, ignoring honorific prefixes.
  # Falls back to a single letter for one-word names / emails.
  def avatar_initials(name)
    tokens = NamePresentation.strip_honorific(name.to_s).gsub(/[^a-zA-Z ]/, " ").split
    initials =
      if tokens.size >= 2
        "#{tokens.first[0]}#{tokens.last[0]}"
      else
        tokens.first.to_s[0, 1]
      end
    initials.upcase.presence || "?"
  end

  # Single source of truth for design-system button styling. These used to be
  # copy-pasted class strings across views, which is how the variants drifted
  # (mismatched heights, ad hoc padding). Repoint every button here instead.
  #
  # All variants are the same size by construction: the fixed `h-10` (40px) height
  # token means `box-sizing: border-box` absorbs the outlined variant's 1px border,
  # so a filled button (no border) and the outlined secondary render identically
  # tall. Do NOT add a `border border-transparent` compensation to the filled
  # variants; the height token already handles it.
  #
  # Keep every class a literal string per variant: Tailwind's source scan
  # (`app/helpers/**/*.rb` is a @source) only sees class names written out in full.
  # Never build them by interpolation (e.g. "bg-#{color}-600") or they won't compile.
  def button_classes(variant = :primary)
    base = "inline-flex h-10 items-center justify-center gap-2 rounded-lg px-4 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-60"
    variant_classes =
      case variant
      when :primary then "bg-brand-600 font-semibold text-white hover:bg-brand-700 focus-visible:ring-brand-500"
      when :secondary then "border border-slate-200 bg-white font-medium text-slate-700 hover:bg-slate-50 focus-visible:ring-brand-500"
      when :danger then "bg-rose-600 font-semibold text-white hover:bg-rose-700 focus-visible:ring-rose-500"
      when :danger_outline then "border border-rose-200 bg-white font-medium text-rose-700 hover:bg-rose-50 focus-visible:ring-rose-500"
      when :success then "bg-emerald-700 font-semibold text-white hover:bg-emerald-800 focus-visible:ring-emerald-500"
      else raise ArgumentError, "unknown button variant: #{variant.inspect}"
      end
    "#{base} #{variant_classes}"
  end

  # Design-system alert/banner card, shared by flash messages (shared/_flashes) and the form-error
  # summary (shared/_form_errors). One shape (rounded-lg border + a leading severity icon), colored
  # by semantic variant. Full class strings written out so the Tailwind scanner compiles them.
  def alert_classes(variant = :info)
    base = "flex items-start gap-2.5 rounded-lg border px-4 py-3 text-sm"
    variant_classes =
      case variant
      when :success then "border-emerald-200 bg-emerald-50 text-emerald-800"
      when :warning then "border-amber-200 bg-amber-50 text-amber-800"
      when :danger then "border-rose-200 bg-rose-50 text-rose-800"
      when :info then "border-brand-200 bg-brand-50 text-brand-800"
      else raise ArgumentError, "unknown alert variant: #{variant.inspect}"
      end
    "#{base} #{variant_classes}"
  end

  def alert_icon(variant = :info)
    case variant
    when :success then "bi-check-circle"
    when :warning, :danger then "bi-exclamation-triangle"
    else "bi-info-circle"
    end
  end

  # Field-level validation (casadesign). Shows WHICH field is invalid, accessibly: a secondary-gray
  # message with a rose leading icon (icon + text center-aligned) rendered right under the field, so
  # the error isn't carried by the border color alone (WCAG 1.4.1). Pair with field_error_attrs to tie the input to the message via
  # aria-describedby + aria-invalid. The shared/_form_errors summary lists the same messages at the
  # top of the form. Renders nothing (nil) when the field is valid.
  #
  #   <%= form.text_field :name, **field_error_attrs(@record, :name) %>
  #   <%= field_error(@record, :name) %>
  #
  # For a radio/checkbox <fieldset>, splat the attrs onto the tag with tag.attributes:
  #   <fieldset <%= tag.attributes(field_error_attrs(@record, :medium_type)) %>>
  def field_error(record, attribute, id: nil)
    return if record.nil? || record.errors[attribute].blank?
    tag.p id: id || field_error_id(record, attribute),
      class: "mt-1.5 flex items-center gap-1.5 text-sm text-slate-500" do
      tag.i(class: "bi bi-exclamation-circle shrink-0 text-rose-600", aria: {hidden: true}) +
        tag.span(record.errors[attribute].to_sentence)
    end
  end

  # aria-* attributes to splat onto the input/select/group for +attribute+ so assistive tech ties it
  # to its field_error message and announces it as invalid. Empty hash (adds nothing) when valid.
  # Pass +id+ to match a field_error rendered with the same +id+ (e.g. unique per nested row).
  def field_error_attrs(record, attribute, id: nil)
    return {} if record.nil? || record.errors[attribute].blank?
    {"aria-invalid": "true", "aria-describedby": id || field_error_id(record, attribute)}
  end

  def field_error_id(record, attribute)
    "#{record.model_name.param_key}_#{attribute}_error"
  end
end
