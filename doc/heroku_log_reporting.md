# Heroku Production Log Reporting

This document details the usage, design, privacy guarantees, and maintainer workflow for `bin/heroku_log_summary.rb`, implemented for GitHub issue [#7264](https://github.com/rubyforgood/casa/issues/7264) ("Safe, aggregate-only production reports for maintainers").

---

## 1. Overview & Purpose

Production debugging often requires inspecting system health, platform crashes, HTTP error bursts, and route usage without compromising sensitive user data. Heroku production logs routinely carry:
- Client IP addresses (`fwd="198.51.100.24"`)
- Secret credentials in query strings (`?auth_token=...`)
- Youth names, emails, and phone numbers in paths or parameters
- Internal request identifiers and host addresses

Sharing raw log lines in GitHub issues, PRs, or chat channels presents serious privacy and security risks.

`bin/heroku_log_summary.rb` solves this by acting as a **safe, aggregate-only analyzer**:
- Extracts platform error codes (`H10`, `H12`, `R14`, etc.).
- Aggregates HTTP 5xx responses by dyno and UTC hour bucket.
- Normalizes URL route patterns (`/casa_cases/12345` &rarr; `/casa_cases/:id`).
- Strictly guarantees that **zero raw logs, zero query parameters, zero IPs, and zero PII** can ever leak into the generated report.
- Operates entirely with the **Ruby standard library** (no external gem or Rails database dependencies required).

---

## 2. Maintainer Workflow

Maintainers can run the script locally against captured Heroku logs using the Heroku CLI or recorded log dumps.

### Workflow A: Piping directly from Heroku CLI (Recommended)

Stream recent production logs directly into the summary script without storing raw logs on disk:

```bash
# Fetch last 1,500 lines from production and generate text report
heroku logs -n 1500 -a casa-production | bin/heroku_log_summary.rb

# Save JSON report to file for automated analysis
heroku logs -n 1500 -a casa-production | bin/heroku_log_summary.rb --json -o tmp/summary.json
```

### Workflow B: Processing recorded log files

If logs were previously saved to an encrypted or temporary file:

```bash
# Process one or more log files into a text summary
bin/heroku_log_summary.rb tmp/heroku_incident.log

# Process multiple log files and output JSON
bin/heroku_log_summary.rb tmp/log1.log tmp/log2.log --json
```

### Workflow C: Sharing findings in GitHub Issues / Discussions

Copy and paste the generated aggregate text report directly into the GitHub issue:
- The output contains only aggregate counts and normalized paths.
- It is completely safe to post publicly in open-source discussions.

---

## 3. Supported Input Formats

The script accepts log streams containing standard Heroku log formats:

1. **Heroku Router Logs**:
   ```
   2026-11-12T03:40:00.123456+00:00 heroku[router]: at=info method=GET path="/casa_cases/12345" host=... dyno=web.1 status=200
   2026-11-12T03:40:00.123456+00:00 heroku[router]: at=error code=H12 desc="Request timeout" method=GET path="/reports" dyno=web.1 status=503
   ```
2. **Heroku Dyno Platform Logs**:
   ```
   2026-11-12T03:40:00.000000+00:00 heroku[web.1]: Error R14 (Memory quota exceeded)
   2026-11-12T03:40:00.000000+00:00 heroku[worker.1]: Error R12 (Exit timeout)
   ```
3. **Logplex Syslog Drains**:
   ```
   <158>1 2026-11-12T03:40:00.123456+00:00 host heroku router - at=error code=H10 ...
   ```
4. **Mixed Application Logs**:
   Interleaved Rails application log lines (e.g. `app[web.1]: Completed 500`) are safely ignored to avoid double-counting router statuses.

---

## 4. Privacy & Redaction Guarantees

The reporting tool is built with a **strict fail-closed, allowlist-only architecture**:

1. **Zero Raw Log Output**:
   Raw log lines are never echoed or retained in output, stderr, or exceptions.
2. **Immediate Query-String & Fragment Stripping**:
   Query parameters (`?...`) and fragments (`#...`) are removed before any path analysis or processing occurs. Sensitive values in query params (e.g. `token=...`, `email=...`) are completely discarded.
3. **Route Normalization**:
   - Numeric database IDs (e.g., `/casa_cases/12345`) are normalized to `/casa_cases/:id`.
   - Nested resources (e.g., `/casa_cases/123/court_dates/456/edit`) become `/casa_cases/:id/court_dates/:id/edit`.
   - UUIDs are normalized to `:id`.
   - ISO dates (e.g., `/reports/2026-11-12`) are normalized to `:date`.
   - Asset digest fingerprints (e.g., `application-0123456789abcdef.js`) are normalized to `:asset`.
4. **Strict Segment Allowlist & Fail Closed**:
   - Each route segment must match either an expected pattern (integer, UUID, date, token) or a known CASA controller/action keyword (e.g., `casa_cases`, `sign_in`, `edit`).
   - If any segment contains unexpected characters (e.g. `@`, `<`, `>`, spaces, path traversal `..`) or unallowlisted arbitrary strings, the route immediately normalizes to `[unrecognized_route]`.
5. **Strict Allow-List Output Formatting**:
   The output data structure consists only of fixed, predefined keys:
   - `report_generated_at`
   - `platform_errors`
   - `http_5xx_by_dyno_and_hour`
   - `routes`
   - `summary`
   Arbitrary log attributes (`fwd`, `request_id`, `host`, `service`, `connect`, etc.) are never passed through.

---

## 5. Command Reference

```
Usage: heroku_log_summary.rb [options] [log_file ...]

Options:
    -f, --format FORMAT              Output format: text (default) or json
        --json                       Shortcut for --format json
    -o, --output FILE                Write report to FILE instead of STDOUT
    -h, --help                       Show this help message
```

### Exit Codes
- `0`: Success
- `1`: File not found or unreadable input file
- `2`: Invalid CLI option / argument parse error
