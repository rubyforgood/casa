module HtmlFormatting
  def html_formatted_list(messages)
    html_string = messages&.join("</li><li>")
    if html_string.present?
      "<ul><li>#{html_string}</li></ul>"
    end
  end
end
