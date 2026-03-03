desc "Post gc stats to discord channel"

task post_gc_stat_to_discord: :environment do
  require "net/http"

  url = URI("https://casavolunteertracking.org/health/gc?token=#{ENV["GC_ACCESS_TOKEN"]}")
  response = Net::HTTP.get_response(url)

  unless response.is_a?(Net::HTTPSuccess)
    raise "Failed to fetch GC stats. HTTP status code:#{response.code}"
  end

  stats = response.body

  unless ENV["DISCORD_WEBHOOK_URL"].nil?
    discord_message = <<~MULTILINE
      ```json
      #{stats}
      ```
    MULTILINE

    payload = {content: discord_message}.to_json

    uri = URI.parse(ENV["DISCORD_WEBHOOK_URL"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")  # Use SSL for HTTPS

    request = Net::HTTP::Post.new(uri.path, {"Content-Type" => "application/json"})
    request.body = payload

    http.request(request)
  end
end
