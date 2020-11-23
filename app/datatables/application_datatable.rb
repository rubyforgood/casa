class ApplicationDatatable
  attr_reader :base_relation, :params

  def initialize(base_relation, params)
    @base_relation = base_relation
    @params = params
  end

  def as_json(*)
    {
      data: sanitize(data),
      recordsFiltered: filtered_records.size,
      recordsTotal: base_relation.size
    }
  end

  private

  def sanitize(data)
    data.map do |record|
      record.transform_values! { |value| ERB::Util.html_escape value }
    end
  end

  def filtered_records
    raw_records
  end

  def paginated_records
    filtered_records
      .offset(offset)
      .limit(limit)
  end
  alias_method :records, :paginated_records

  def additional_filters
    @additional_filters ||= params[:additional_filters] || {}
  end

  def search_term
    @search_term ||= params[:search][:value]
  end

  def order_by
    @order_by ||= params[:columns][order_column_index][:data]
  end

  def order_column_index
    params[:order]["0"][:column]
  end

  def order_direction
    params[:order]["0"][:dir] || "ASC"
  end

  def limit
    (params[:length] || 10).to_i
  end

  def offset
    params[:start].to_i
  end

  def bool_filter(filter)
    # expects filter to be an array

    if filter.blank?
      "FALSE"
    elsif filter.length > 1
      "TRUE"
    else
      yield
    end
  end
end
