module CssHelpers
  # Returns a hash of _specified_ (as opposed to runtime-adjusted/overridden) CSS attributes for an element
  def specified_style_attributes(capybara_element)
    style_string = capybara_element["style"]
    attribute_strings = style_string.split(";")
    attribute_strings.each_with_object({}) do |string, style_hash|
      first_colon_position = string.index(":")
      key = string[0...first_colon_position].strip
      value = string[(first_colon_position + 1)..-1].strip
      style_hash[key] = value
    end
  end
end
