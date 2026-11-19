#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "time"

# HerokuLogSummary parses recorded Heroku production logs and produces
# aggregate-only reports for maintainers. It strictly redacts and strips all
# sensitive information (PII, query parameters, passwords, tokens, IP addresses)
# and fails closed whenever routes or values cannot be safely normalized.
class HerokuLogSummary
  SAFE_PATH_REGEX = %r{\A/[a-zA-Z0-9_\-./]*\z}
  SAFE_DYNO_REGEX = /\A[a-zA-Z0-9_-]+(?:\.[0-9]+)?\z/
  SAFE_CODE_REGEX = /\A[A-Z]\d{2,3}\z/
  UUID_REGEX = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/
  INTEGER_ID_REGEX = /\A\d+(\.[a-zA-Z]{1,5})?\z/
  HEX_TOKEN_REGEX = /\A[0-9a-fA-F]{16,}\z/
  DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/
  ASSET_REGEX = /\A[a-zA-Z0-9_-]+-[0-9a-fA-F]{8,}\.[a-zA-Z0-9]+\z/

  # Allowlist of safe, standard file extensions for web assets and documents
  SAFE_EXTENSIONS = %w[.json .csv .docx .pdf .xml .html .css .js .png .jpg .jpeg .svg .ico .txt .map].freeze

  # Allowlist of exact known root or fixed application paths
  KNOWN_EXACT_PATHS = [
    "/",
    "/up",
    "/health",
    "/health/old_objects",
    "/export_emails",
    "/pg_dashboard",
    "/api-docs",
    "/.well-known/assetlinks.json",
    "/favicon.ico",
    "/robots.txt"
  ].freeze

  # Allowlist of known safe resource nouns and controller actions in CASA
  KNOWN_SEGMENT_KEYWORDS = %w[
    accept
    activate
    all_casa_admins
    analytics
    api-docs
    assets
    attachments
    banners
    blobs
    cancel
    case_contact_reports
    case_contacts
    case_court_reports
    casa_admins
    casa_cases
    casa_org
    change_to_supervisor
    check
    checklist_items
    confirmations
    confirmation
    contact_topic_answers
    contact_topics
    contact_type_groups
    contact_types
    copy_court_orders
    court_dates
    create
    dashboard
    deactivate
    destroy
    discard_draft
    dismiss
    download_failed
    drafts
    edit
    emancipation
    emancipation_checklists
    export_emails
    followup_reports
    followups
    form
    fund_request
    generate
    health
    hearing_types
    imports
    index
    invitations
    invitation
    judges
    learning_hour_topics
    learning_hour_types
    learning_hours_reports
    leave
    mark_as_complete
    mark_as_needs_review
    mark_as_read
    mileage_rates
    mileage_reports
    missing_data_reports
    new
    new_design
    notifications
    old_objects
    other_duties
    passwords
    password
    pg_dashboard
    placement_reports
    placement_types
    placements
    preference_sets
    rails
    reactivate
    reimbursements
    reports
    representations
    resend_invitation
    resolve
    restore
    save
    send_reactivation_alert
    sessions
    show
    sign_in
    sign_out
    soft_delete
    supervisors
    table_state
    table_state_update
    update
    users
    volunteers
  ].freeze

  attr_reader :platform_errors, :http_5xx_by_dyno_and_hour, :route_counts, :summary

  def initialize
    @platform_errors = Hash.new(0)
    @http_5xx_by_dyno_and_hour = Hash.new { |h, k| h[k] = Hash.new(0) }
    @route_counts = Hash.new(0)
    @summary = {
      total_lines: 0,
      router_lines: 0,
      dyno_lines: 0,
      http_5xx_count: 0,
      platform_error_count: 0,
      unrecognized_lines: 0,
      earliest_timestamp: nil,
      latest_timestamp: nil
    }
  end

  def process_io(io)
    io.each_line do |line|
      process_line(line)
    end
  end

  def process_string(content)
    content.each_line do |line|
      process_line(line)
    end
  end

  def process_line(raw_line)
    return if raw_line.nil?

    # Sanitize encoding and length to prevent decoding or buffer anomalies
    clean_line = raw_line.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?").strip
    return if clean_line.empty?

    # Fail closed on excessively large lines (anti-DoS safeguard)
    if clean_line.bytesize > 8192
      @summary[:total_lines] += 1
      @summary[:unrecognized_lines] += 1
      return
    end

    @summary[:total_lines] += 1

    extract_timestamp(clean_line)
    errors_found = extract_platform_errors(clean_line)

    if router_line?(clean_line)
      @summary[:router_lines] += 1
      process_router_line(clean_line)
    elsif dyno_line?(clean_line)
      @summary[:dyno_lines] += 1
    elsif !errors_found
      @summary[:unrecognized_lines] += 1
    end
  end

  def to_h
    {
      report_generated_at: Time.now.utc.iso8601,
      platform_errors: @platform_errors.sort.to_h,
      http_5xx_by_dyno_and_hour: sort_5xx_hash(@http_5xx_by_dyno_and_hour),
      routes: @route_counts.sort_by { |route, count| [-count, route] }.to_h,
      summary: @summary.dup
    }
  end

  def to_json(*_args)
    JSON.pretty_generate(to_h)
  end

  def to_text
    data = to_h
    lines = []
    lines << "=" * 80
    lines << "                       HEROKU LOG SUMMARY REPORT"
    lines << "=" * 80
    lines << "Generated At: #{data[:report_generated_at]}"
    lines << ""
    lines << "-" * 80
    lines << "1. Platform Errors"
    lines << "-" * 80
    if data[:platform_errors].empty?
      lines << "  None detected"
    else
      data[:platform_errors].each do |code, count|
        lines << format("  %-10s : %d", code, count)
      end
      lines << "  Total platform errors: #{data[:summary][:platform_error_count]}"
    end
    lines << ""
    lines << "-" * 80
    lines << "2. HTTP 5xx Errors (by Dyno and Hour UTC)"
    lines << "-" * 80
    if data[:http_5xx_by_dyno_and_hour].empty?
      lines << "  None detected"
    else
      data[:http_5xx_by_dyno_and_hour].each do |hour, dynos|
        lines << "  Hour: #{hour}"
        dynos.each do |dyno, count|
          lines << format("    %-12s : %d", dyno, count)
        end
      end
      lines << "  Total 5xx responses: #{data[:summary][:http_5xx_count]}"
    end
    lines << ""
    lines << "-" * 80
    lines << "3. Route Patterns (Normalized)"
    lines << "-" * 80
    if data[:routes].empty?
      lines << "  None detected"
    else
      data[:routes].each do |route, count|
        lines << format("  %-50s : %d", route, count)
      end
    end
    lines << ""
    lines << "-" * 80
    lines << "4. Processing Summary"
    lines << "-" * 80
    lines << "  Total lines processed   : #{data[:summary][:total_lines]}"
    lines << "  Router lines            : #{data[:summary][:router_lines]}"
    lines << "  Dyno runtime lines      : #{data[:summary][:dyno_lines]}"
    lines << "  Platform error count    : #{data[:summary][:platform_error_count]}"
    lines << "  HTTP 5xx error count    : #{data[:summary][:http_5xx_count]}"
    lines << "  Unrecognized lines      : #{data[:summary][:unrecognized_lines]}"
    lines << "  Earliest timestamp      : #{data[:summary][:earliest_timestamp] || "N/A"}"
    lines << "  Latest timestamp        : #{data[:summary][:latest_timestamp] || "N/A"}"
    lines << "=" * 80
    lines.join("\n")
  end

  def normalize_route(raw_path)
    return "[unrecognized_route]" if raw_path.to_s.empty?

    # Immediately strip query strings and URL fragments
    path_only = raw_path.split("?").first.to_s.split("#").first.to_s.strip

    # Fail closed on empty paths, relative paths, or suspicious control/traversal characters
    return "[unrecognized_route]" unless path_only.start_with?("/")
    return "[unrecognized_route]" if path_only.include?("//") || path_only.include?("..") || path_only.include?("@")
    return "[unrecognized_route]" unless path_only.match?(SAFE_PATH_REGEX)

    # Check exact match allowlist
    return path_only if KNOWN_EXACT_PATHS.include?(path_only)

    segments = path_only.split("/").reject(&:empty?)
    return "/" if segments.empty?
    return "[unrecognized_route]" if segments.size > 12

    normalized_segments = []

    segments.each do |seg|
      if seg.match?(UUID_REGEX)
        normalized_segments << ":id"
      elsif seg.match?(INTEGER_ID_REGEX)
        ext = File.extname(seg).downcase
        if ext.empty?
          normalized_segments << ":id"
        elsif SAFE_EXTENSIONS.include?(ext)
          normalized_segments << ":id#{ext}"
        else
          return "[unrecognized_route]"
        end
      elsif seg.match?(HEX_TOKEN_REGEX)
        normalized_segments << ":token"
      elsif seg.match?(DATE_REGEX)
        normalized_segments << ":date"
      elsif seg.match?(ASSET_REGEX)
        normalized_segments << ":asset"
      else
        base_name = File.basename(seg, ".*").downcase
        ext = File.extname(seg).downcase

        if KNOWN_SEGMENT_KEYWORDS.include?(seg.downcase)
          normalized_segments << seg.downcase
        elsif !ext.empty? && SAFE_EXTENSIONS.include?(ext) && KNOWN_SEGMENT_KEYWORDS.include?(base_name)
          normalized_segments << "#{base_name}#{ext}"
        else
          # Fail closed: an unallowlisted, unidentifiable segment is never printed
          return "[unrecognized_route]"
        end
      end
    end

    "/" + normalized_segments.join("/")
  end

  private

  def router_line?(line)
    line.include?("heroku[router]") || line.include?("heroku router")
  end

  def dyno_line?(line)
    line.match?(/\bheroku\[[a-zA-Z0-9_\-.]+\]:/)
  end

  def extract_platform_errors(line)
    # Only trust platform error signals originating from Heroku platform prefixes
    return false unless line.match?(/\bheroku(?:\[[a-zA-Z0-9_\-.]+\]|\s+router\b)/)

    detected = []

    line.scan(/\bcode=["']?([A-Z]\d{2,3})["']?\b/) do |match|
      code = match[0]
      detected << code if code.match?(SAFE_CODE_REGEX)
    end

    line.scan(/\bError\s+([A-Z]\d{2,3})\b/) do |match|
      code = match[0]
      detected << code if code.match?(SAFE_CODE_REGEX)
    end

    detected.uniq.each do |code|
      @platform_errors[code] += 1
      @summary[:platform_error_count] += 1
    end

    !detected.empty?
  end

  def process_router_line(line)
    # Process HTTP status code
    if line =~ /\bstatus=(\d{3})\b/
      status_code = $1.to_i
      if status_code.between?(500, 599)
        dyno = extract_dyno(line)
        hour = extract_hour_bucket(line)
        @http_5xx_by_dyno_and_hour[hour][dyno] += 1
        @summary[:http_5xx_count] += 1
      end
    end

    # Process route path
    raw_path = extract_path(line)
    if raw_path
      norm_route = normalize_route(raw_path)
      @route_counts[norm_route] += 1
    end
  end

  def extract_path(line)
    if line =~ /\bpath="([^"]*)"/
      $1
    elsif line =~ /\bpath=([^\s]+)/
      $1
    end
  end

  def extract_dyno(line)
    if line =~ /\bdyno=["']?([a-zA-Z0-9_\-.]+)["']?/
      candidate = $1
      candidate.match?(SAFE_DYNO_REGEX) ? candidate : "(unknown)"
    else
      "(unassigned)"
    end
  end

  def extract_timestamp(line)
    if line =~ /\b(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2}))\b/
      raw_ts = $1
      begin
        formatted = Time.iso8601(raw_ts).utc.iso8601
        @summary[:earliest_timestamp] = formatted if @summary[:earliest_timestamp].nil? || formatted < @summary[:earliest_timestamp]
        @summary[:latest_timestamp] = formatted if @summary[:latest_timestamp].nil? || formatted > @summary[:latest_timestamp]
      rescue ArgumentError, TypeError
        # Ignore unparseable timestamps
      end
    end
  end

  def extract_hour_bucket(line)
    if line =~ /\b(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2}))\b/
      raw_ts = $1
      begin
        return Time.iso8601(raw_ts).utc.strftime("%Y-%m-%dT%H:00:00Z")
      rescue ArgumentError, TypeError
        # Fall back to regex hour extraction if iso8601 parser errors
      end
    end

    if line =~ /\b(\d{4}-\d{2}-\d{2}T\d{2}):/
      "#{$1}:00:00Z"
    else
      "unknown_hour"
    end
  end

  def sort_5xx_hash(hash)
    hash.keys.sort.each_with_object({}) do |hour, acc|
      acc[hour] = hash[hour].sort.to_h
    end
  end

  # CLI runner for invoking from terminal or pipes
  class CLI
    def self.run(argv)
      options = {
        format: :text,
        output: nil
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: heroku_log_summary.rb [options] [log_file ...]"

        opts.on("-f", "--format FORMAT", %i[text json], "Output format: text (default) or json") do |fmt|
          options[:format] = fmt.to_sym
        end

        opts.on("--json", "Shortcut for --format json") do
          options[:format] = :json
        end

        opts.on("-o", "--output FILE", "Write report to FILE instead of STDOUT") do |file|
          options[:output] = file
        end

        opts.on("-h", "--help", "Show this help message") do
          puts opts
          return 0
        end
      end

      parser.parse!(argv)

      analyzer = HerokuLogSummary.new

      begin
        if argv.empty? || argv == ["-"]
          analyzer.process_io($stdin)
        else
          argv.each do |file_path|
            unless File.file?(file_path) && File.readable?(file_path)
              warn "Error: Unable to read file '#{File.basename(file_path)}'"
              return 1
            end
            File.open(file_path, "r:UTF-8") do |f|
              analyzer.process_io(f)
            end
          end
        end

        report = (options[:format] == :json) ? analyzer.to_json : analyzer.to_text

        if options[:output]
          File.write(options[:output], report)
        else
          puts report
        end

        0
      rescue OptionParser::ParseError => e
        warn "Error: #{e.message}"
        warn "Run with --help for usage details."
        2
      rescue
        warn "Error: Failed to process log input."
        1
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  exit HerokuLogSummary::CLI.run(ARGV)
end
