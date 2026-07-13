module TableHelper
  # A sortable column header: an <th aria-sort> containing a link that toggles the
  # sort direction, plus a double-caret indicator whose active half is brand-coloured.
  # Sorting is server-side, so the link preserves the current query (filters) and
  # resets the page. `column` must be whitelisted by the controller.
  def sortable_header(label, column, sort:, direction:)
    active = column.to_s == sort.to_s
    state = active ? direction : "none"
    aria = {"asc" => "ascending", "desc" => "descending"}.fetch(state, "none")
    next_direction = (active && direction == "asc") ? "desc" : "asc"
    href = url_for(request.query_parameters.merge("sort" => column.to_s, "direction" => next_direction).except("page"))
    link_class = "inline-flex items-center rounded text-xs font-semibold #{active ? "text-slate-900" : "text-slate-600"} hover:text-slate-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500"
    content_tag(:th, class: "px-4 py-3 text-left", "aria-sort": aria) do
      link_to(href, class: link_class) { safe_join([label, sort_caret(state)]) }
    end
  end

  def sort_caret(state)
    up = caret_color(state, "asc")
    down = caret_color(state, "desc")
    raw(%(<span class="inline-flex" style="margin-left:4px" aria-hidden="true"><svg width="8" height="12" viewBox="0 0 8 12" fill="none"><path d="M0.75 5 L4 2 L7.25 5" stroke="#{up}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M0.75 7 L4 10 L7.25 7" stroke="#{down}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></span>))
  end

  # Brand for the active half, light for the other half of a sorted column, mid when unsorted.
  def caret_color(state, half)
    return "#94a3b8" if state == "none"
    (state == half) ? "#4f46e5" : "#cbd5e1"
  end
end
