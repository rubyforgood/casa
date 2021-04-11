# config/initializers/paper_trail.rb

# Record paper_trail whodunnit in rails console also
# Defer evaluation in case we're using spring loader (otherwise it would be something like "spring app    | app | started 13 secs ago | development")
PaperTrail.request.whodunnit = lambda {
  if Rails.const_defined?("Console") || File.basename($PROGRAM_NAME) == "rake"
    "#{`whoami`.strip}: console"
  else
    "#{`whoami`.strip}: #{File.basename($PROGRAM_NAME)} #{ARGV.join " "}"
  end
}

PaperTrail.config.enabled = true
PaperTrail.config.has_paper_trail_defaults = {
  on: %i[create update destroy]
}
PaperTrail.config.version_limit = 10
