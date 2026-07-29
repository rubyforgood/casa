# Shared name-formatting helpers. User display names should never show an
# honorific prefix (Mr./Mrs./Ms./...) anywhere in the app — see User#display_name.
module NamePresentation
  HONORIFICS = %w[mr mrs ms miss mx dr prof rev sir madam].freeze

  module_function

  # "Mrs. Hung Bergstrom" -> "Hung Bergstrom"; names without a leading
  # honorific are returned unchanged.
  def strip_honorific(name)
    parts = name.to_s.split(" ")
    return name.to_s if parts.size <= 1

    leading = parts.first.sub(/\.\z/, "").downcase
    HONORIFICS.include?(leading) ? parts.drop(1).join(" ") : name.to_s
  end
end
