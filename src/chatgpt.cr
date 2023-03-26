require "option_parser"
require "http/client"
require "json"
require "colorize"
require "readline"
require "spinner"
require "lexbor"

require "./chatgpt/file_extensions"
require "./chatgpt/post_data"
require "./chatgpt/client"
require "./chatgpt/system_command"
require "./chatgpt/magic_command"
require "./chatgpt/webpage_compressor"
require "./chatgpt/cli/version"
require "./chatgpt/cli/parser"

DEBUG_FLAG = [false]

# Create the base directory if it doesn't exist
unless Dir.exists?(ChatGPT::Config::BASE_DIR)
  Dir.mkdir_p(ChatGPT::Config::BASE_DIR)
end
# FIXME
File.open(ChatGPT::Config::RESPONSE_FILE, "w") { |f| f.print("") }

command_parser = ChatGPT::CLI::Parser.new
command_parser.parse
post_data = command_parser.data

gpt_client = ChatGPT::Client.new
system_command = ChatGPT::SystemCommand.new
magic_command = ChatGPT::MagicCommand.new(post_data, key: "%")

def process_url_substitution(url_match)
  url = url_match[3..-2].strip
  url = "https://" + url unless url.starts_with?("http")
  compressed_text = words(Lexbor::Parser.new(HTTP::Client.get(url).body.to_s)).join("|")

  <<-CODE_BLOCK
    ### #{url}

    ```
    #{compressed_text}
    ```

    That's all for the #{url}
  CODE_BLOCK
end

def process_file_substitution(file_pattern, file_match)
  file_paths = Dir.glob(file_pattern)

  if file_paths.empty?
    STDERR.puts "Warning: No files found matching: #{file_pattern} leave it as it is".colorize(:yellow).mode(:bold)
    return file_match
  end

  content_blocks = file_paths.map do |file_path|
    extname = File.extname(file_path)
    basename = File.basename(file_path)
    begin
      contents = File.read(file_path)
    rescue ex
      # This should not happen because we already checked the file exists with Dir.glob
      STDERR.puts "Error: #{ex}\nFailed to read file: #{file_path}".colorize(:yellow).mode(:bold)
      contents = "# Error: Failed to read file: #{file_path}"
    end
    format_name = ChatGPT::FILE_EXTENSIONS.fetch(extname, "")

    <<-CODE_BLOCK
    ### #{basename}

    ```#{format_name}
    #{contents}
    ```

    That's all for the #{basename}

    CODE_BLOCK
  end

  content_blocks.join("\n")
end


def process_stdout_substitution(stdout_match, system_command)

    <<-CODE_BLOCK

    ```
    #{system_command.last_stdout}
    ```

    CODE_BLOCK
end

def process_stderr_substitution(stderr_match, system_command)

    <<-CODE_BLOCK

    command: `#{system_command.last_command}`

    ```error
    #{system_command.last_stderr}
    ```

    CODE_BLOCK
end

loop do
  input_msg = Readline.readline("#{post_data.model}> ", true)
  break if input_msg.nil?
  next if input_msg.empty?
  break if ["exit", "quit"].includes?(input_msg)

  next if system_command.try_run(input_msg)

  if modified_post_data = magic_command.try_run(input_msg, post_data)
    post_data = modified_post_data if modified_post_data.is_a?(ChatGPT::PostData)
    next
  end

  input_msg = input_msg.gsub(/%%{.+?}/) { |url_match| process_url_substitution(url_match) }
  input_msg = input_msg.gsub(/%{.+?}/) { |file_match| process_file_substitution(file_match[2..-2].strip, file_match) }
  input_msg = input_msg.gsub(/%STDOUT/) { |stdout_match| process_stdout_substitution(stdout_match, system_command) }
  input_msg = input_msg.gsub(/%STDERR/) { |stderr_match| process_stderr_substitution(stderr_match, system_command) }

  post_data.messages << {"role" => "user", "content" => input_msg}
  response = gpt_client.send_chat_request(post_data)
  response_data = JSON.parse(response.body)
  File.write(ChatGPT::Config::RESPONSE_FILE, response_data.to_pretty_json)

  if response.success?
    result_msg = response_data["choices"][0]["message"]["content"]
    post_data.messages << {"role" => "assistant", "content" => result_msg.to_s}
    File.write(ChatGPT::Config::POST_DATA_FILE, post_data.to_pretty_json)
    puts result_msg.colorize(:green)
  else
    STDERR.puts "Error: #{response.status_code} #{response.status}".colorize(:yellow).mode(:bold)
    STDERR.puts response.body.colorize(:yellow)
    exit 1
  end
end
