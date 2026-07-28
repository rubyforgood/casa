# frozen_string_literal: true

require "net/http"
desc "Post gc stats to discord channel"

CODE_BLOCK_DELIMITER_END = "\n...```"
CODE_BLOCK_DELIMITER_START = "```json\n"
DISCORD_MESSAGE_LIMIT = 2000
TOTAL_DELIMITER_LENGTH = CODE_BLOCK_DELIMITER_END.length + CODE_BLOCK_DELIMITER_START.length

task post_gc_stat_to_discord: :environment do
  fetch_env_vars => {access_token:, discord_webhook_url:}

  stats = fetch_memory_profile(access_token)
  message_chunks = chunk_profile_stats(stats)
  send_discord_message_chunked(message_chunks)
end

def chunk_long_code_block_message(long_message)
  if long_message.length <= DISCORD_MESSAGE_LIMIT
    return [long_message]
  end

  first_chunk, long_message = split_single_chunk(long_message, DISCORD_MESSAGE_LIMIT - CODE_BLOCK_DELIMITER_END.length)

  chunks = [first_chunk]

  while long_message.length > DISCORD_MESSAGE_LIMIT
    puts long_message
    chunk, long_message = split_single_chunk(long_message, DISCORD_MESSAGE_LIMIT - TOTAL_DELIMITER_LENGTH)

    chunks.push(chunk)
  end

  chunks.push(long_message)

  chunks
end

def chunk_profile_stats(stats_as_json_string)
  # parsing the json string consumes memory
  old_object_count = get_old_object_count_low_memory_usage(stats_as_json_string)
  sample_hour = get_sample_time_low_memory_usage(stats_as_json_string)

  largest_old_objects_by_class = get_json_array_value_as_string(stats_as_json_string, "\"largest_old_objects_by_class\": [")
  most_common_old_object_classes = get_json_array_value_as_string(stats_as_json_string, "\"most_common_old_object_classes\": [")
  most_common_old_strings = get_json_array_value_as_string(stats_as_json_string, "\"most_common_old_strings\": [")

  part_1 = <<~MULTILINE
    Hour: #{sample_hour}
    Old Object Count: #{old_object_count}

    Largest Classes in Old Objects
    ```ruby
    #{largest_old_objects_by_class}
    ```
  MULTILINE

  part_2 = <<~MULTILINE
    Most Common Old Objects
    ```ruby
    #{most_common_old_object_classes}
    ```
  MULTILINE

  part_3 = <<~MULTILINE
    Most Common Old Strings
    ```ruby
    #{most_common_old_strings}
    ```
  MULTILINE

  chunk_long_code_block_message(part_1).concat(chunk_long_code_block_message(part_2)).concat(chunk_long_code_block_message(part_3))
end

def is_valid_discord_message(value)
  value.is_a?(String) && value.length <= DISCORD_MESSAGE_LIMIT
end

def enclose_chunked_code_blocks(chunks)
  if chunks.length < 2
    return chunks
  end

  chunks[0] += CODE_BLOCK_DELIMITER_END
  chunks[-1] = CODE_BLOCK_DELIMITER_START + chunks[-1]

  1..chunks.length - 2.each do |i|
    chunks[i] = CODE_BLOCK_DELIMITER_START + chunks[i] + CODE_BLOCK_DELIMITER_END
  end
end

def fetch_env_vars
  access_token = ENV.fetch("GC_ACCESS_TOKEN")
  discord_webhook_url = ENV.fetch("DISCORD_WEBHOOK_URL")

  {
    access_token:,
    discord_webhook_url:
  }
end

def fetch_memory_profile(access_token)
  url = URI("https://casavolunteertracking.org/health/old_objects?token=#{access_token}")
  response = Net::HTTP.get_response(url)

  unless response.is_a?(Net::HTTPSuccess)
    raise "Failed to fetch GC stats. HTTP status code:#{response.code}"
  end

  response.body
end

def get_array_closing_bracket_index(opening_bracket_index, stats_as_json_string)
  nest_level = 1

  search_index = opening_bracket_index + 1

  while search_index < stats_as_json_string.length
    current_character = stats_as_json_string[search_index]

    if current_character == "["
      nest_level += 1
    elsif current_character == "]"
      nest_level -= 1

      if nest_level == 0
        return search_index
      end
    end

    search_index += 1
  end

  -1
end

def get_json_array_value_as_string(stats_as_json_string, string_with_key)
  start_index = stats_as_json_string.index(string_with_key) + string_with_key.length - 1
  stop_index = get_array_closing_bracket_index(start_index, stats_as_json_string)

  stats_as_json_string[start_index, stop_index - start_index + 1].gsub("\n  ", "\n")
end

def get_old_object_count_low_memory_usage(stats_as_json_string)
  old_object_count_marker = '"old_object_count": '
  old_object_count_start_index = stats_as_json_string.index(/#{old_object_count_marker}\d+,/) + old_object_count_marker.length
  old_object_count_stop_index = old_object_count_start_index

  while stats_as_json_string[old_object_count_stop_index] != ","
    old_object_count_stop_index += 1
  end

  stats_as_json_string[old_object_count_start_index, old_object_count_stop_index - old_object_count_start_index]
end

def get_sample_time_low_memory_usage(stats_as_json_string)
  sample_time_marker = 'sample_time": "'
  sample_time_start_index = stats_as_json_string.index(/#{sample_time_marker}\d+"/) + sample_time_marker.length
  sample_time_count_stop_index = sample_time_start_index

  while stats_as_json_string[sample_time_count_stop_index] != '"'
    sample_time_count_stop_index += 1
  end

  stats_as_json_string[sample_time_start_index, sample_time_count_stop_index - sample_time_start_index]
end

def send_discord_message(message)
  unless is_valid_discord_message(message)
    raise ArgumentError, "argument message must be a string with a maximum length of #{DISCORD_MESSAGE_LIMIT} characters"
  end

  payload = {content: message}.to_json

  uri = URI.parse(ENV["DISCORD_WEBHOOK_URL"])
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")

  request = Net::HTTP::Post.new(uri.path, {"Content-Type" => "application/json"})
  request.body = payload

  http.request(request)
end

def send_discord_message_chunked(message_chunks)
  message_chunks.each do |chunk|
    request_result = send_discord_message(chunk)
    verify_discord_message_posted(request_result)
    sleep 0.5
  end
end

def split_single_chunk(message, max_chunk_size)
  if message.length <= max_chunk_size
    return ["", message]
  end

  last_newline_index = max_chunk_size - 1

  while last_newline_index > 0 && message[last_newline_index] != "\n"
    last_newline_index -= 1
  end

  if last_newline_index == 0
    [message[0, max_chunk_size], message[max_chunk_size, message.length]]
  else
    [message[0, last_newline_index], message[last_newline_index + 1, message.length]]
  end
end

def verify_discord_message_posted(request_result)
  status_code_as_number = Integer(request_result.code)
  unless status_code_as_number >= 200 && status_code_as_number < 300
    raise "Failed to send discord message. HTTP status code:#{request_result.code}"
  end
end
