desc "Post gc stats to discord channel"

task post_gc_stat_to_discord: :environment do
  stats = GC.stat

  unless ENV["DISCORD_WEBHOOK_URL"].nil?
    formatted_stats = JSON.pretty_generate(stats)
    discord_message = <<~MULTILINE
      ```json
      #{formatted_stats}
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
