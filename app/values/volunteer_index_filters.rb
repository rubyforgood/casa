# Normalizes the volunteers index's plain GET filters (search/status/supervisor/transition/
# languages/sort/direction), rejecting anything not in the allowed set, and maps them into the
# DataTables param shape VolunteerDatatable understands — so the migrated (bespoke Pagy) index
# reuses the datatable's exact filter/search/order SQL.
class VolunteerIndexFilters
  STATUSES = %w[active inactive all].freeze
  YES_NO = %w[yes no].freeze
  DEFAULT_STATUS = "active"
  DEFAULT_SORT = "display_name"

  attr_reader :search, :status, :supervisor, :transition, :extra_languages, :sort, :direction

  # supervisor_ids: the ids (as strings) of the org's active supervisors, used to expand the
  # "all supervisors" filter — see #supervisor_filter.
  def initialize(params, supervisor_ids: [])
    @search = params[:search].to_s
    @status = STATUSES.include?(params[:status]) ? params[:status] : DEFAULT_STATUS
    @supervisor = params[:supervisor].to_s
    @transition = YES_NO.include?(params[:transition]) ? params[:transition] : ""
    @extra_languages = YES_NO.include?(params[:languages]) ? params[:languages] : ""
    @sort = VolunteerDatatable::ORDERABLE_FIELDS.include?(params[:sort]) ? params[:sort] : DEFAULT_SORT
    @direction = (params[:direction] == "desc") ? "desc" : "asc"
    @supervisor_ids = supervisor_ids
  end

  def to_datatable_params
    {
      search: {value: search},
      additional_filters: {
        active: active_filter,
        supervisor: supervisor_filter,
        transition_aged_youth: yes_no_filter(transition, default: %w[true false]),
        extra_languages: yes_no_filter(extra_languages, default: nil)
      },
      columns: {"0" => {name: sort}},
      order: {"0" => {column: "0", dir: direction}}
    }.with_indifferent_access
  end

  private

  attr_reader :supervisor_ids

  def active_filter
    case status
    when "inactive" then %w[false]
    when "all" then %w[true false]
    else %w[true]
    end
  end

  # The datatable's supervisor filter is value-list based: [""] means "no supervisor", a list of
  # ids means those supervisors, and "" mixed with ids means "null OR those". "All" therefore
  # passes "" + every active supervisor id so it also includes volunteers whose supervisor is
  # inactive/absent (their joined supervisor is null).
  def supervisor_filter
    case supervisor
    when "", "all" then ["", *supervisor_ids]
    when "unassigned" then [""]
    else [supervisor]
    end
  end

  def yes_no_filter(value, default:)
    value.present? ? [(value == "yes").to_s] : default
  end
end
