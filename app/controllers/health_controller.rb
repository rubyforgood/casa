require "objspace"

class HealthController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :verify_token_for_old_object_stats, only: [:old_objects]

  # Public ops health check. HTML renders a minimal, self-contained status page; JSON
  # returns the latest deploy time (consumed by uptime monitors). Activity charts have
  # moved to the authenticated all-CASA "Metrics" console and the per-chapter "Analytics"
  # page (see MetricsReport), so this public endpoint exposes no cross-org data.
  def index
    respond_to do |format|
      format.html { render :index, layout: false }
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

  private

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
