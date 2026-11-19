# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require_relative "../../bin/heroku_log_summary"

RSpec.describe HerokuLogSummary do
  subject(:analyzer) { described_class.new }

  let(:fixture_path) { File.expand_path("../fixtures/files/heroku_logs/recorded_heroku.log", __dir__) }
  let(:fixture_content) { File.read(fixture_path) }

  describe "Platform error-code aggregation" do
    it "aggregates router error codes correctly" do
      log_lines = <<~LOG
        2026-11-12T03:00:00Z heroku[router]: at=error code=H12 desc="Request timeout" method=GET path="/casa_cases" status=503
        2026-11-12T03:01:00Z heroku[router]: at=error code=H12 desc="Request timeout" method=GET path="/casa_cases" status=503
        2026-11-12T03:02:00Z heroku[router]: at=error code=H10 desc="App crashed" method=POST path="/users/sign_in" status=503
        2026-11-12T03:03:00Z heroku[router]: at=error code=H13 desc="Connection dropped" method=GET path="/reports" status=503
      LOG

      analyzer.process_string(log_lines)
      expect(analyzer.platform_errors).to eq("H12" => 2, "H10" => 1, "H13" => 1)
      expect(analyzer.summary[:platform_error_count]).to eq(4)
    end

    it "aggregates dyno runtime error codes (R-series)" do
      log_lines = <<~LOG
        2026-11-12T03:00:00Z heroku[web.1]: Error R14 (Memory quota exceeded)
        2026-11-12T03:01:00Z heroku[web.1]: Error R14 (Memory quota exceeded)
        2026-11-12T03:02:00Z heroku[web.2]: Error R15 (Memory quota vastly exceeded)
        2026-11-12T03:03:00Z heroku[worker.1]: Error R12 (Exit timeout)
      LOG

      analyzer.process_string(log_lines)
      expect(analyzer.platform_errors).to eq("R14" => 2, "R15" => 1, "R12" => 1)
    end

    it "does not extract false error codes from application log lines" do
      log_lines = <<~LOG
        2026-11-12T03:00:00Z app[web.1]: [req-123] User message said: I saw Error R14 in documentation
        2026-11-12T03:01:00Z app[web.1]: [req-124] Parameter code=H12 was submitted
      LOG

      analyzer.process_string(log_lines)
      expect(analyzer.platform_errors).to be_empty
      expect(analyzer.summary[:platform_error_count]).to eq(0)
    end
  end

  describe "HTTP 5xx aggregation by dyno and hour" do
    it "buckets 5xx errors by dyno and UTC hour bucket" do
      log_lines = <<~LOG
        2026-11-12T02:15:00.000000+00:00 heroku[router]: at=info method=GET path="/casa_cases" dyno=web.1 status=500
        2026-11-12T02:45:00.000000+00:00 heroku[router]: at=info method=GET path="/casa_cases" dyno=web.1 status=503
        2026-11-12T03:10:00.000000+00:00 heroku[router]: at=info method=GET path="/casa_cases" dyno=web.2 status=502
        2026-11-12T03:20:00.000000+00:00 heroku[router]: at=info method=GET path="/casa_cases" dyno=web.1 status=504
        2026-11-12T03:50:00.000000+00:00 heroku[router]: at=info method=GET path="/casa_cases" dyno= status=503
      LOG

      analyzer.process_string(log_lines)
      expected = {
        "2026-11-12T02:00:00Z" => {"web.1" => 2},
        "2026-11-12T03:00:00Z" => {"(unassigned)" => 1, "web.1" => 1, "web.2" => 1}
      }
      expect(analyzer.http_5xx_by_dyno_and_hour).to eq(expected)
      expect(analyzer.summary[:http_5xx_count]).to eq(5)
    end

    it "consistently converts non-UTC timestamp offsets (+04:00) into UTC hour buckets" do
      log_line = '2026-11-12T07:15:00.000000+04:00 heroku[router]: at=info method=GET path="/health" dyno=web.2 status=500'
      analyzer.process_line(log_line)
      expect(analyzer.http_5xx_by_dyno_and_hour).to have_key("2026-11-12T03:00:00Z")
      expect(analyzer.http_5xx_by_dyno_and_hour["2026-11-12T03:00:00Z"]).to eq("web.2" => 1)
    end

    it "converts timestamps crossing day boundaries (-05:00) into correct UTC date and hour" do
      log_line = '2026-11-12T20:15:00.000000-05:00 heroku[router]: at=info method=GET path="/health" dyno=web.1 status=503'
      analyzer.process_line(log_line)
      expect(analyzer.http_5xx_by_dyno_and_hour).to have_key("2026-11-13T01:00:00Z")
      expect(analyzer.http_5xx_by_dyno_and_hour["2026-11-13T01:00:00Z"]).to eq("web.1" => 1)
    end

    it "does not count 2xx, 3xx, 4xx responses as 5xx errors" do
      log_lines = <<~LOG
        2026-11-12T03:00:00Z heroku[router]: at=info method=GET path="/casa_cases" dyno=web.1 status=200
        2026-11-12T03:01:00Z heroku[router]: at=info method=GET path="/users/sign_in" dyno=web.1 status=302
        2026-11-12T03:02:00Z heroku[router]: at=info method=GET path="/missing" dyno=web.1 status=404
        2026-11-12T03:03:00Z heroku[router]: at=info method=POST path="/case_contacts" dyno=web.1 status=422
      LOG

      analyzer.process_string(log_lines)
      expect(analyzer.http_5xx_by_dyno_and_hour).to be_empty
      expect(analyzer.summary[:http_5xx_count]).to eq(0)
    end

    it "avoids double counting Rails app log completion messages" do
      log_lines = <<~LOG
        2026-11-12T03:00:00Z heroku[router]: at=info method=GET path="/casa_cases" dyno=web.1 status=500
        2026-11-12T03:00:01Z app[web.1]: Completed 500 Internal Server Error in 35ms
      LOG

      analyzer.process_string(log_lines)
      expect(analyzer.summary[:http_5xx_count]).to eq(1)
    end
  end

  describe "Route pattern normalization" do
    it "normalizes dynamic integer IDs to :id" do
      expect(analyzer.normalize_route("/casa_cases/12345")).to eq("/casa_cases/:id")
      expect(analyzer.normalize_route("/supervisors/99")).to eq("/supervisors/:id")
      expect(analyzer.normalize_route("/volunteers/42")).to eq("/volunteers/:id")
    end

    it "normalizes nested dynamic path segments" do
      expect(analyzer.normalize_route("/casa_cases/12345/court_dates/6789/edit")).to eq("/casa_cases/:id/court_dates/:id/edit")
      expect(analyzer.normalize_route("/case_contacts/10/form/20")).to eq("/case_contacts/:id/form/:id")
    end

    it "normalizes UUIDs to :id" do
      uuid_path = "/casa_cases/c3b8a1e2-9b2c-4f1e-8e1d-1a2b3c4d5e6f"
      expect(analyzer.normalize_route(uuid_path)).to eq("/casa_cases/:id")
    end

    it "normalizes safe allowed document formats" do
      expect(analyzer.normalize_route("/casa_cases/12345.json")).to eq("/casa_cases/:id.json")
      expect(analyzer.normalize_route("/case_court_reports/12345.docx")).to eq("/case_court_reports/:id.docx")
      expect(analyzer.normalize_route("/case_court_reports.csv")).to eq("/case_court_reports.csv")
    end

    it "strips query strings before normalizing" do
      path_with_query = "/casa_cases/12345?email=admin%40casa.org&token=secret123"
      expect(analyzer.normalize_route(path_with_query)).to eq("/casa_cases/:id")
    end

    it "strips URL fragments before normalizing" do
      path_with_fragment = "/casa_cases/12345#court-orders"
      expect(analyzer.normalize_route(path_with_fragment)).to eq("/casa_cases/:id")
    end

    it "normalizes asset fingerprinted paths" do
      expect(analyzer.normalize_route("/assets/application-0123456789abcdef.css")).to eq("/assets/:asset")
    end

    it "preserves exact allowlisted paths" do
      expect(analyzer.normalize_route("/")).to eq("/")
      expect(analyzer.normalize_route("/up")).to eq("/up")
      expect(analyzer.normalize_route("/health")).to eq("/health")
      expect(analyzer.normalize_route("/.well-known/assetlinks.json")).to eq("/.well-known/assetlinks.json")
    end
  end

  describe "Fail-closed handling on non-normalizable or suspicious routes" do
    it "fails closed on paths containing email addresses (plain or URL-encoded)" do
      expect(analyzer.normalize_route("/users/sarah@example.com/profile")).to eq("[unrecognized_route]")
      expect(analyzer.normalize_route("/users/sarah%40example.com/profile")).to eq("[unrecognized_route]")
    end

    it "fails closed on paths containing IP addresses (plain or URL-encoded)" do
      expect(analyzer.normalize_route("/supervisors/192.168.1.1")).to eq("[unrecognized_route]")
      expect(analyzer.normalize_route("/supervisors/10.0.0.1")).to eq("[unrecognized_route]")
      expect(analyzer.normalize_route("/supervisors/192%2E168%2E1%2E1")).to eq("[unrecognized_route]")
    end

    it "fails closed on path traversal attempts" do
      expect(analyzer.normalize_route("/../../../etc/shadow")).to eq("[unrecognized_route]")
      expect(analyzer.normalize_route("/casa_cases/../etc")).to eq("[unrecognized_route]")
      expect(analyzer.normalize_route("/casa_cases/%2e%2e/etc")).to eq("[unrecognized_route]")
    end

    it "fails closed on unapproved file extension exploit attempts" do
      expect(analyzer.normalize_route("/users.secret_credential")).to eq("[unrecognized_route]")
      expect(analyzer.normalize_route("/casa_cases/123.secret")).to eq("[unrecognized_route]")
    end

    it "fails closed on XSS or HTML injection attempts" do
      expect(analyzer.normalize_route("/users/<script>alert('xss')</script>")).to eq("[unrecognized_route]")
    end

    it "fails closed on non-allowlisted path segments" do
      expect(analyzer.normalize_route("/arbitrary_unknown_controller/super_secret_action")).to eq("[unrecognized_route]")
    end

    it "fails closed on relative or malformed paths" do
      expect(analyzer.normalize_route("evil.com/phish")).to eq("[unrecognized_route]")
      expect(analyzer.normalize_route("")).to eq("[unrecognized_route]")
      expect(analyzer.normalize_route(nil)).to eq("[unrecognized_route]")
    end
  end

  describe "Malformed input handling" do
    it "handles non-log garbage text gracefully without raising exceptions" do
      malformed_text = "RANDOM GARBAGE DATA WITH NO STRUCTURE %%% $$$ ***"
      expect { analyzer.process_line(malformed_text) }.not_to raise_error
      expect(analyzer.summary[:unrecognized_lines]).to eq(1)
    end

    it "handles invalid byte sequences gracefully" do
      corrupted_line = (+"2026-11-12T03:00:00Z heroku[router]: \xFF\xFE status=500").force_encoding("ASCII-8BIT")
      expect { analyzer.process_line(corrupted_line) }.not_to raise_error
    end

    it "handles excessively long lines without crashing" do
      oversized_line = "2026-11-12T03:00:00Z heroku[router]: " + ("A" * 10_000)
      expect { analyzer.process_line(oversized_line) }.not_to raise_error
      expect(analyzer.summary[:unrecognized_lines]).to eq(1)
    end
  end

  describe "Privacy and leak prevention guarantees" do
    let(:fake_sensitive_values) do
      [
        "sarah.admin@casa-volunteer.org",
        "ghp_ABC1234567890XYZSECRETTOKEN",
        "555-867-5309",
        "987-65-4321",
        "Jane Doe",
        "SuperSecretPassword123!",
        "198.51.100.24",
        "203.0.113.88",
        "198.51.100.99",
        "9f8c4b2a-1122-3344-5566-778899aabbcc",
        "sarah@example.com",
        "admin@example.com",
        "super_private_fragment_secret",
        "secret_credential",
        "top_secret_query",
        "SECRET_USER_999",
        "4111-2222-3333-4444",
        "192.168.1.1",
        "/etc/shadow",
        "<script>"
      ]
    end

    before do
      analyzer.process_string(fixture_content)
    end

    it "never outputs fake PII or secrets in the text report" do
      report_text = analyzer.to_text

      fake_sensitive_values.each do |sensitive_value|
        expect(report_text).not_to include(sensitive_value)
      end
    end

    it "never outputs fake PII or secrets in the JSON report" do
      report_json = analyzer.to_json

      fake_sensitive_values.each do |sensitive_value|
        expect(report_json).not_to include(sensitive_value)
      end
    end

    it "never outputs raw dynamic IDs in route pattern counts" do
      expect(analyzer.route_counts.keys).not_to include("/casa_cases/12345")
      expect(analyzer.route_counts.keys).not_to include("/casa_cases/67890")
      expect(analyzer.route_counts.keys).to include("/casa_cases/:id")
    end
  end

  describe "Strict allow-list output schema" do
    before do
      analyzer.process_string(fixture_content)
    end

    it "produces a hash with only allowed top-level keys" do
      allowed_keys = %i[
        report_generated_at
        platform_errors
        http_5xx_by_dyno_and_hour
        routes
        summary
      ]
      expect(analyzer.to_h.keys).to match_array(allowed_keys)
    end

    it "produces a summary with only allowed summary keys" do
      allowed_summary_keys = %i[
        total_lines
        router_lines
        dyno_lines
        http_5xx_count
        platform_error_count
        unrecognized_lines
        earliest_timestamp
        latest_timestamp
      ]
      expect(analyzer.to_h[:summary].keys).to match_array(allowed_summary_keys)
    end

    it "does not expose arbitrary log fields (fwd, host, request_id, user_id, credit_card) in report" do
      report_hash = analyzer.to_h
      serialized_keys = report_hash.to_s

      %w[fwd host request_id service connect bytes protocol user_id credit_card].each do |field|
        expect(report_hash[:summary].keys).not_to include(field.to_sym)
        expect(serialized_keys).not_to match(/"#{field}"=>/)
      end
    end
  end

  describe "CLI execution" do
    it "runs with --json and outputs valid JSON" do
      output = `ruby bin/heroku_log_summary.rb --json #{fixture_path}`
      parsed = JSON.parse(output)
      expect(parsed).to have_key("platform_errors")
      expect(parsed).to have_key("http_5xx_by_dyno_and_hour")
      expect(parsed).to have_key("routes")
      expect(parsed).to have_key("summary")
    end

    it "runs with --output and writes report to the specified file" do
      Tempfile.create(["heroku_report", ".txt"]) do |temp_file|
        exit_code = HerokuLogSummary::CLI.run(["-o", temp_file.path, fixture_path])
        expect(exit_code).to eq(0)
        expect(File.read(temp_file.path)).to include("HEROKU LOG SUMMARY REPORT")
      end
    end

    it "returns error code 1 when given a non-existent file" do
      exit_code = HerokuLogSummary::CLI.run(["non_existent_file.log"])
      expect(exit_code).to eq(1)
    end

    it "suppresses stack traces and raw error output when an unexpected error occurs" do
      allow(File).to receive(:open).and_raise(RuntimeError, "Secret database error line containing sensitive text")
      expect {
        exit_code = HerokuLogSummary::CLI.run([fixture_path])
        expect(exit_code).to eq(1)
      }.to output("Error: Failed to process log input.\n").to_stderr
    end
  end
end
