module ChangedAttributes
  def changed_attributes_messages(original, changed)
    changed_attributes = changed.select { |k, v| original[k] != v }.keys.delete_if { |k| k == :updated_at }
    return if changed_attributes.empty?

    changed_attributes.map do |att|
      change_message_text(att, original[att], changed[att])
    end.delete_if(&:nil?)
  end

  def change_message_text(attribute, original_attribute, updated_attribute)
    if attribute == :contact_types
      new_contact_type_ids = updated_attribute.map { |contact| contact["contact_type_id"] }
      previous_contact_type_ids = original_attribute.map { |contact| contact["contact_type_id"] }
      changed_count = new_contact_type_ids - previous_contact_type_ids
      return if changed_count == 0
      "#{changed_count} #{attribute.to_s.humanize.singularize.pluralize(changed_count)} added"
    elsif attribute == :court_orders
      changed_count = (updated_attribute - original_attribute).count
      "#{changed_count} #{attribute.to_s.humanize.singularize.pluralize(changed_count)} added or updated"
    else
      "Changed #{attribute.to_s.gsub(/_id\Z/, "").humanize}"
    end
  end
end
