module DesignSystemHelper
  # A person's display name with any honorific prefix removed (Mrs. Hung Bergstrom
  # -> Hung Bergstrom), falling back to their email. Use this everywhere a user's
  # name is shown so names render consistently without honorifics.
  def display_person(user)
    NamePresentation.strip_honorific(user.display_name.presence || user.email)
  end

  # Two-letter initials for avatars: first + last name, ignoring honorific
  # prefixes. Falls back to a single letter for one-word names / emails.
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
end
