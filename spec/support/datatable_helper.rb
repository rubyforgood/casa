module DatatableHelper
  def datatable_params(order_by:, additional_filters: {}, order_direction: "ASC", page: nil, per_page: nil, search_term: nil)
    if page.present?
      raise ":per_page argument required when :page present" if per_page.blank?

      start = [page - 1, 0].max * per_page
    end

    {
      additional_filters: additional_filters,
      columns: {"0" => {name: order_by}},
      length: per_page,
      order: {"0" => {column: "0", dir: order_direction}},
      search: {value: search_term},
      start: start
    }
  end

  def described_class
    class_name = self.class.name.split("::")[2]
    class_name.constantize
  rescue NameError
    # TODO warning log to bugsnag here ?
  end

  def escaped(value)
    ERB::Util.html_escape value
  end
end
