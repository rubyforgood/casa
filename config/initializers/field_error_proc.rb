# Design-system field-level validation, applied to EVERY form automatically via Rails' global
# field_error_proc (which wraps each rendered form field whose attribute has an error).
#
# For a text-like control (input / select / textarea; not radio / checkbox / hidden) it keeps the
# .field_with_errors wrapper (rose border, styled in tailwind.css), adds aria-invalid, and appends a
# single secondary-gray message + rose icon underneath -- the same treatment as the field_error
# helper. It SKIPS a control that already carries aria-describedby, i.e. a field that opted into the
# helper by hand (the case-contact fieldsets), so those messages are never doubled. Labels, radios,
# checkboxes and hidden inputs are still wrapped for the border but get no auto message (grouped
# controls surface through their group's field_error or the summary banner).
#
# Only runs on invalid fields (error re-renders), so the Nokogiri pass is not on the hot path.
Rails.application.config.action_view.field_error_proc = proc do |html_tag, instance|
  control = nil
  begin
    fragment = Nokogiri::HTML::DocumentFragment.parse(html_tag)
    control = fragment.at_css("input:not([type='hidden']):not([type='radio']):not([type='checkbox']), select, textarea")
  rescue
    control = nil
  end

  message = ""
  if control && control["aria-describedby"].to_s.strip.empty?
    object = instance.instance_variable_get(:@object)
    method = instance.instance_variable_get(:@method_name)
    errors = (object.respond_to?(:errors) && method) ? object.errors[method] : []
    if errors.present?
      object_name = instance.instance_variable_get(:@object_name).to_s
      error_id = "#{object_name}_#{method}_error".parameterize(separator: "_")
      control["aria-invalid"] = "true"
      control["aria-describedby"] = error_id
      html_tag = fragment.to_html.html_safe
      msg = ERB::Util.html_escape(errors.to_sentence.upcase_first)
      message = %(<p id="#{error_id}" class="mt-1.5 flex items-center gap-1.5 text-sm text-slate-500"><i class="bi bi-exclamation-circle shrink-0 text-rose-600" aria-hidden="true"></i><span>#{msg}</span></p>)
    end
  end

  %(<div class="field_with_errors">#{html_tag}</div>#{message}).html_safe
end
