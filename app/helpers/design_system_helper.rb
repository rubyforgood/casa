module DesignSystemHelper
  HONORIFICS = %w[mr mrs ms miss mx dr prof rev sir madam].freeze

  # Two-letter initials for avatars: first + last name, ignoring honorific
  # prefixes (Mr, Mrs, Ms, ...). Falls back to a single letter for one-word
  # names or email-based fallbacks.
  def avatar_initials(name)
    tokens = name.to_s.gsub(/[^a-zA-Z ]/, " ").split
    tokens = tokens.reject { |token| HONORIFICS.include?(token.downcase) } if tokens.size > 1
    initials =
      if tokens.size >= 2
        "#{tokens.first[0]}#{tokens.last[0]}"
      else
        tokens.first.to_s[0, 1]
      end
    initials.upcase.presence || "?"
  end
end
