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
end
