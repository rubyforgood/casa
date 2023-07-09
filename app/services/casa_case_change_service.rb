class CasaCaseChangeService
  def initialize(original, changed)
    @original = original
    @changed = changed
  end

  attr_reader :original, :changed

  def calculate
    html_formatted_list(changed_attributes_messages)
  end

  def changed_attributes_messages
    changed_attributes = changed.select { |k, v| original[k] != v }.keys.delete_if { |k| k.in?(%i[updated_at slug]) }
    return if changed_attributes.empty?

    changed_attributes.map do |att|
      change_message_text(att, original[att], changed[att])
    end.delete_if(&:nil?)
  end

  private

  def html_formatted_list(messages)
    html_string = messages&.join("</li><li>")
    if html_string.present?
      "<ul><li>#{html_string}</li></ul>"
    end
  end

  def change_message_text(attribute, original_attribute, updated_attribute)
    if attribute == :contact_types
      new_contact_types = updated_attribute.map { |contact| contact["name"] }
      previous_contact_types = original_attribute.map { |contact| contact["name"] }
      changed_contact_types = new_contact_types - previous_contact_types
      return if changed_contact_types.empty?
      "#{changed_contact_types} #{attribute.to_s.humanize.singularize.pluralize(changed_contact_types)} added"
    elsif attribute == :court_orders
      changed_count = (updated_attribute - original_attribute).count
      "#{changed_count} #{attribute.to_s.humanize.singularize.pluralize(changed_count)} added or updated"
    else
      "Changed #{attribute.to_s.gsub(/_id\Z/, "").humanize}"
    end
  end
end
