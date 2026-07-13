module HealthHelper
  SERIES_COLORS = %w[#4f46e5 #059669 #d97706 #e11d48].freeze
  SERIES_DASH = ["", "7 4", "1.5 4", "10 4 1.5 4"].freeze
  SERIES_SHAPE = %i[circle square triangle diamond].freeze
  HEATMAP_RAMP = %w[#eef2ff #c7d2fe #a5b4fc #818cf8 #6366f1 #4338ca].freeze
  DAY_LABELS = %w[Sun Mon Tue Wed Thu Fri Sat].freeze

  def metric_tiles(items)
    tag.div(safe_join(items.map { |item| metric_tile(item) }), class: "flex flex-wrap gap-3")
  end

  def metric_empty_state(heading, body)
    tag.div(class: "rounded-2xl border border-dashed border-slate-300 bg-white px-6 py-10 text-center") do
      safe_join([
        tag.div(empty_chart_icon, class: "mx-auto mb-3 flex justify-center text-slate-400"),
        tag.p(heading, class: "text-[15px] font-bold text-slate-900"),
        tag.p(body, class: "mx-auto mt-1 max-w-[46ch] text-sm text-slate-600")
      ])
    end
  end

  def metric_legend(series)
    items = series.each_with_index.map do |ser, i|
      tag.span(class: "inline-flex items-center gap-1.5 text-[13px] text-slate-600") do
        safe_join([line_key_svg(i), tag.span(ser[:name])])
      end
    end
    tag.div(safe_join(items), class: "mt-3 flex flex-wrap gap-x-4 gap-y-2")
  end

  def metric_line_chart(id, labels, series, title:, desc:)
    raw(build_line_chart(id, labels, series, title, desc))
  end

  def metric_data_table(labels, series, caption:, foot: nil, footnote: nil)
    th = "px-2.5 py-1.5 text-right text-xs font-semibold text-slate-500"
    th_row = "px-2.5 py-1.5 text-left text-xs font-semibold text-slate-700"
    td = "px-2.5 py-1.5 text-right text-xs tabular-nums text-slate-700"
    header = tag.tr(class: "border-b border-slate-200") do
      safe_join([tag.th("Month", scope: "col", class: "#{th} text-left")] +
        series.map { |ser| tag.th(ser[:name], scope: "col", class: th) })
    end
    rows = labels.each_with_index.map do |lab, i|
      tag.tr(class: (i.zero? ? "" : "border-t border-slate-50")) do
        safe_join([tag.th(lab, scope: "row", class: th_row)] +
          series.map { |ser| tag.td(ser[:data][i], class: td) })
      end
    end
    foot_html = if foot
      tag.tfoot(tag.tr(safe_join(
        [tag.th(foot[:label], scope: "row", class: "#{th_row} border-t-2 border-slate-200 text-slate-900")] +
        foot[:cells].map { |c| tag.td(c, class: "#{td} border-t-2 border-slate-200 font-bold text-slate-900") }
      )))
    else
      "".html_safe
    end
    table = tag.table(class: "w-full") do
      safe_join([tag.caption(caption, class: "sr-only"), tag.thead(header), tag.tbody(safe_join(rows)), foot_html])
    end
    tag.details(class: "mt-3 border-t border-slate-100 pt-2.5") do
      safe_join([
        tag.summary("View as table", class: "w-max cursor-pointer text-[13px] font-medium text-brand-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500"),
        tag.div(table, class: "mt-2.5 overflow-x-auto"),
        (footnote ? tag.p(footnote, class: "mt-2 text-[11px] text-slate-500") : "".html_safe)
      ])
    end
  end

  def metric_heatmap(grid, max)
    hours = (0..23).to_a
    header = tag.tr do
      safe_join([tag.th(tag.span("Day of week", class: "sr-only"), scope: "col", class: "px-1 py-1")] +
        hours.map { |hr| tag.th(hr, scope: "col", class: "px-1 py-1 text-center text-[10px] font-medium text-slate-500") })
    end
    rows = DAY_LABELS.each_with_index.map do |day, di|
      cells = hours.map do |hr|
        count = grid[[di, hr]] || 0
        tag.td(count.positive? ? count : "",
          style: "background:#{heat_color(count, max)};color:#{heat_ink(count, max)}",
          class: "w-[30px] min-w-[30px] rounded border-2 border-white py-1 text-center text-[11px]",
          title: "#{day} #{hr}:00, #{count} #{"contact".pluralize(count)}")
      end
      tag.tr(safe_join([tag.th(day, scope: "row", class: "px-1 py-1 pr-2.5 text-right text-[11px] font-semibold text-slate-700")] + cells))
    end
    tag.div(class: "overflow-x-auto") do
      tag.table(class: "border-collapse") do
        safe_join([
          tag.caption("Case contacts created by day of week (rows) and hour of day (columns, 0 to 23). Cell shade and number both encode the count.", class: "sr-only"),
          tag.thead(header),
          tag.tbody(safe_join(rows))
        ])
      end
    end
  end

  private

  def metric_tile(item)
    value = item[:value]
    value_html =
      if value.nil?
        tag.div("No data", class: "pt-1 text-[15px] font-semibold leading-tight text-slate-600")
      elsif value.zero?
        tag.div("0", class: "text-2xl font-bold leading-none text-slate-500")
      else
        tag.div(value, class: "text-2xl font-bold leading-none text-slate-900")
      end
    tag.div(class: "min-w-[130px] flex-1 rounded-xl bg-slate-50 px-3.5 py-3") do
      safe_join([
        value_html,
        tag.div(item[:label], class: "mt-1 text-sm text-slate-600"),
        tag.div(item[:sub], class: "text-[11px] text-slate-500")
      ])
    end
  end

  def build_line_chart(id, labels, series, title, desc)
    w = 720
    h = 300
    pad_l = 42
    pad_r = 40
    pad_t = 16
    pad_b = 34
    plot_w = w - pad_l - pad_r
    plot_h = h - pad_t - pad_b
    ymax = nice_ceiling(series.flat_map { |s| s[:data] }.max.to_i)
    n = labels.size
    xx = ->(i) { (pad_l + plot_w * i.to_f / [n - 1, 1].max).round(1) }
    yy = ->(v) { (pad_t + plot_h * (1 - v.to_f / ymax)).round(1) }
    out = %(<svg viewBox="0 0 #{w} #{h}" width="100%" class="block h-auto w-full" role="img" aria-labelledby="#{id}-t #{id}-d" preserveAspectRatio="xMidYMid meet">)
    out << %(<title id="#{id}-t">#{h(title)}</title><desc id="#{id}-d">#{h(desc)}</desc>)
    4.downto(0) do |t|
      frac = t / 4.0
      y = (pad_t + plot_h * (1 - frac)).round(1)
      out << %(<line x1="#{pad_l}" y1="#{y}" x2="#{pad_l + plot_w}" y2="#{y}" stroke="#e2e8f0" stroke-width="1"/>)
      out << %(<text x="#{pad_l - 8}" y="#{y + 4}" text-anchor="end" font-size="11" fill="#64748b">#{(ymax * frac).round}</text>)
    end
    labels.each_with_index do |lab, i|
      out << %(<text x="#{xx.call(i)}" y="#{h - 12}" text-anchor="middle" font-size="11" fill="#64748b">#{h(lab)}</text>)
    end
    out << %(<line x1="#{pad_l}" y1="#{pad_t + plot_h}" x2="#{pad_l + plot_w}" y2="#{pad_t + plot_h}" stroke="#cbd5e1" stroke-width="1"/>)
    series.each_with_index do |ser, si|
      color = series_color(si)
      dash = series_dash(si)
      dash_attr = dash.empty? ? "" : %( stroke-dasharray="#{dash}")
      pts = ser[:data].each_with_index.map { |v, i| "#{xx.call(i)},#{yy.call(v)}" }.join(" ")
      out << %(<polyline points="#{pts}" fill="none" stroke="#{color}" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"#{dash_attr}/>)
      ser[:data].each_with_index do |v, i|
        out << %(<g><title>#{h(ser[:name])}, #{h(labels[i])}: #{v}</title>#{metric_marker(SERIES_SHAPE[si], xx.call(i), yy.call(v), color)}</g>)
      end
      out << %(<text x="#{xx.call(n - 1) + 8}" y="#{yy.call(ser[:data].last) + 4}" font-size="11" font-weight="700" fill="#0f172a">#{ser[:data].last}</text>)
    end
    out << "</svg>"
    out
  end

  def line_key_svg(i)
    color = series_color(i)
    dash = series_dash(i)
    dash_attr = dash.empty? ? "" : %( stroke-dasharray="#{dash}")
    raw(%(<svg width="36" height="12" aria-hidden="true"><line x1="1" y1="6" x2="35" y2="6" stroke="#{color}" stroke-width="2"#{dash_attr}/>#{metric_marker(SERIES_SHAPE[i], 18, 6, color, 3.1)}</svg>))
  end

  def metric_marker(shape, cx, cy, color, r = 3.6)
    case shape
    when :circle
      %(<circle cx="#{cx}" cy="#{cy}" r="#{r}" fill="#{color}" stroke="#ffffff" stroke-width="2"/>)
    when :square
      s = r * 1.8
      %(<rect x="#{(cx - s / 2).round(1)}" y="#{(cy - s / 2).round(1)}" width="#{s.round(1)}" height="#{s.round(1)}" rx="1" fill="#{color}" stroke="#ffffff" stroke-width="2"/>)
    when :triangle
      s = r * 2.2
      %(<polygon points="#{cx},#{(cy - s * 0.6).round(1)} #{(cx - s * 0.55).round(1)},#{(cy + s * 0.45).round(1)} #{(cx + s * 0.55).round(1)},#{(cy + s * 0.45).round(1)}" fill="#{color}" stroke="#ffffff" stroke-width="2" stroke-linejoin="round"/>)
    else
      s = r * 1.5
      %(<polygon points="#{cx},#{(cy - s).round(1)} #{(cx + s).round(1)},#{cy} #{cx},#{(cy + s).round(1)} #{(cx - s).round(1)},#{cy}" fill="#{color}" stroke="#ffffff" stroke-width="2" stroke-linejoin="round"/>)
    end
  end

  def nice_ceiling(v)
    return 5 if v <= 5
    mag = 10**Math.log10(v).floor
    [1, 2, 2.5, 5, 10].map { |f| f * mag }.find { |c| c >= v } || 10 * mag
  end

  def heat_color(count, max)
    return "#f8fafc" if count <= 0 || max <= 0
    idx = [((count.to_f / max) * (HEATMAP_RAMP.size - 1)).round, HEATMAP_RAMP.size - 1].min
    HEATMAP_RAMP[idx]
  end

  def heat_ink(count, max)
    (max.positive? && count.to_f / max > 0.55) ? "#ffffff" : "#334155"
  end

  def empty_chart_icon
    raw(%(<svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><path d="M3 3v18h18" stroke-linecap="round"/><path d="M7 15l3-3 3 2 4-5" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="2 3"/></svg>))
  end

  def series_color(i) = SERIES_COLORS[i % SERIES_COLORS.size]

  def series_dash(i) = SERIES_DASH[i % SERIES_DASH.size]
end
