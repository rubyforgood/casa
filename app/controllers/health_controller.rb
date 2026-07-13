require "objspace"

class HealthController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does
  before_action :verify_token_for_old_object_stats, only: [:old_objects]

  def index
    respond_to do |format|
      format.html do
        @case_contacts = monthly_case_contacts
        @active_users = monthly_active_users
        @contact_heatmap = contact_creation_heatmap
        render :index, layout: "metrics"
      end

      format.json { render json: {latest_deploy_time: Health.instance.latest_deploy_time} }
    end
  end

  def old_objects
    render body: JSON.pretty_generate({
      largest_old_objects_by_class: get_top_20_hash_keys_by_value_desc(find_largest_old_objects_by_class),
      most_common_old_object_classes: get_top_20_hash_keys_by_value_desc(find_most_common_old_object_classes),
      most_common_old_strings: encode_string_hash_to_utf_8(get_top_20_hash_keys_by_value_desc(find_most_common_old_strings)),
      old_object_count: GC.stat[:old_objects],
      sample_time: Time.now.in_time_zone("Central Time (US & Canada)").strftime("%H")
    }),
      content_type: "application/json"
  end

  def case_contacts_creation_times_in_last_week
    case_contacts_created_in_last_week = CaseContact.where("created_at >= ?", 1.week.ago)

    unix_timestamps_of_case_contacts_created_in_last_week = case_contacts_created_in_last_week.pluck(:created_at).map { |creation_time| creation_time.to_i }

    render json: {timestamps: unix_timestamps_of_case_contacts_created_in_last_week}
  end

  def monthly_line_graph_data
    first_day_of_last_12_months = (12.months.ago.to_date..Date.current).select { |date| date.day == 1 }.map { |date| date.beginning_of_month }

    if first_day_of_last_12_months.size > 12
      first_day_of_last_12_months = first_day_of_last_12_months[1..12]
    end

    monthly_counts_of_case_contacts_created = CaseContact.group_by_month(:created_at, last: 12).count
    monthly_counts_of_case_contacts_with_notes_created = CaseContact.left_outer_joins(:contact_topic_answers).where("case_contacts.notes != '' OR contact_topic_answers.value != ''").select(:id).distinct.group_by_month(:created_at, last: 12).count
    monthly_counts_of_users_who_have_created_case_contacts = CaseContact.select(:creator_id).distinct.group_by_month(:created_at, last: 12).count

    monthly_line_graph_combined_data = first_day_of_last_12_months.map do |month|
      [
        month.strftime("%b %Y"),
        monthly_counts_of_case_contacts_created[month],
        monthly_counts_of_case_contacts_with_notes_created[month],
        monthly_counts_of_users_who_have_created_case_contacts[month]
      ]
    end

    render json: monthly_line_graph_combined_data
  end

  def monthly_unique_users_graph_data
    first_day_of_last_12_months = (12.months.ago.to_date..Date.current).select { |date| date.day == 1 }.map { |date| date.beginning_of_month.strftime("%b %Y") }

    if first_day_of_last_12_months.size > 12
      first_day_of_last_12_months = first_day_of_last_12_months[1..12]
    end

    monthly_counts_of_volunteers = LoginActivity.joins("INNER JOIN users ON users.id = login_activities.user_id AND login_activities.user_type = 'User'").where(users: {type: "Volunteer"}, success: true).group_by_month(:created_at, format: "%b %Y").distinct.count(:user_id)
    monthly_counts_of_supervisors = LoginActivity.joins("INNER JOIN users ON users.id = login_activities.user_id AND login_activities.user_type = 'User'").where(users: {type: "Supervisor"}, success: true).group_by_month(:created_at, format: "%b %Y").distinct.count(:user_id)
    monthly_counts_of_casa_admins = LoginActivity.joins("INNER JOIN users ON users.id = login_activities.user_id AND login_activities.user_type = 'User'").where(users: {type: "CasaAdmin"}, success: true).group_by_month(:created_at, format: "%b %Y").distinct.count(:user_id)
    monthly_logged_counts_of_volunteers = CaseContact.joins(supervisor_volunteer: :volunteer).group_by_month(:created_at, format: "%b %Y").distinct.count(:creator_id)

    monthly_line_graph_combined_data = first_day_of_last_12_months.map do |month|
      [
        month,
        monthly_counts_of_volunteers[month] || 0,
        monthly_counts_of_supervisors[month] || 0,
        monthly_counts_of_casa_admins[month] || 0,
        monthly_logged_counts_of_volunteers[month] || 0
      ]
    end

    render json: monthly_line_graph_combined_data
  end

  private

  MONTHS_BACK = 12

  def last_12_month_starts
    (0..MONTHS_BACK - 1).map { |i| (MONTHS_BACK - 1 - i).months.ago.beginning_of_month }
  end

  def monthly_case_contacts
    months = last_12_month_starts
    pick = ->(counts) { months.map { |m| counts.find { |k, _| k.year == m.year && k.month == m.month }&.last || 0 } }
    total = CaseContact.group_by_month(:created_at, last: MONTHS_BACK).count
    with_notes = CaseContact.where.not(notes: [nil, ""]).group_by_month(:created_at, last: MONTHS_BACK).count
    loggers = CaseContact.group_by_month(:created_at, last: MONTHS_BACK).distinct.count(:creator_id)
    {
      labels: months.map { |m| m.strftime("%b") },
      series: [
        {name: "Total contacts", data: pick.call(total)},
        {name: "With notes", data: pick.call(with_notes)},
        {name: "Unique loggers", data: pick.call(loggers)}
      ],
      distinct_loggers: CaseContact.where(created_at: months.first..).distinct.count(:creator_id)
    }
  end

  def monthly_active_users
    months = last_12_month_starts
    keys = months.map { |m| m.strftime("%b %Y") }
    by_type = ->(type) {
      LoginActivity
        .joins("INNER JOIN users ON users.id = login_activities.user_id AND login_activities.user_type = 'User'")
        .where(users: {type: type}, success: true)
        .group_by_month(:created_at, format: "%b %Y").distinct.count(:user_id)
    }
    volunteers = by_type.call("Volunteer")
    supervisors = by_type.call("Supervisor")
    admins = by_type.call("CasaAdmin")
    logged = CaseContact.joins(supervisor_volunteer: :volunteer).group_by_month(:created_at, format: "%b %Y").distinct.count(:creator_id)
    {
      labels: months.map { |m| m.strftime("%b") },
      series: [
        {name: "Volunteers", data: keys.map { |k| volunteers[k] || 0 }},
        {name: "Supervisors", data: keys.map { |k| supervisors[k] || 0 }},
        {name: "Admins", data: keys.map { |k| admins[k] || 0 }},
        {name: "Active loggers", data: keys.map { |k| logged[k] || 0 }}
      ]
    }
  end

  def contact_creation_heatmap
    grid = CaseContact.where(created_at: MONTHS_BACK.months.ago.beginning_of_month..)
      .group("EXTRACT(DOW FROM created_at)::int")
      .group("EXTRACT(HOUR FROM created_at)::int").count
    {grid: grid, max: grid.values.max || 0}
  end

  def each_old_object
    ObjectSpace.each_object do |obj|
      next unless ObjectSpace.dump(obj).include?('"old":true')
      yield obj
    rescue NoMethodError
      next
    end
  end

  def encode_string_hash_to_utf_8(hash)
    hash.map do |str, count|
      [str.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?"), count]
    end
  end

  def find_largest_old_objects_by_class
    class_sizes = Hash.new(0)

    each_old_object do |obj|
      klass = obj.class
      class_sizes[klass] += ObjectSpace.memsize_of(obj)
    rescue
      next
    end

    class_sizes
  end

  def find_most_common_old_object_classes
    class_counts = Hash.new(0)

    each_old_object do |obj|
      klass = obj.class
      class_counts[klass] += 1
    rescue
      next
    end

    class_counts
  end

  def find_most_common_old_strings
    string_counts = Hash.new(0)

    each_old_object do |obj|
      string_counts[obj] += 1 if obj.is_a?(String) && !obj.frozen?
    rescue NoMethodError
      next
    end

    string_counts
  end

  def get_top_20_hash_keys_by_value_desc(hash)
    hash.sort_by do |key, val|
      -val
    end.first(20)
  end

  def verify_token_for_old_object_stats
    gc_access_token = ENV["GC_ACCESS_TOKEN"]

    head :forbidden unless params[:token] == gc_access_token && !gc_access_token.nil?
  end
end
