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

parser = ChatGPT::CLI::Parser.new
parser.parse
data = parser.data

client = ChatGPT::Client.new
system_cmd = ChatGPT::SystemCommand.new
magic_cmd = ChatGPT::MagicCommand.new(data, key: "%")

def process_url_substitution(match)
  url = match[3..-2].strip
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

def process_file_substitution(path, match)
  extname = File.extname(path)
  basename = File.basename(path)
  format_name = ChatGPT::FILE_EXTENSIONS.fetch(extname, "")

  if File.exists?(path)
    <<-CODE_BLOCK
      ### #{basename}

      ```#{format_name}
      #{File.read(path)}
      ```

      That's all for the #{basename}
    CODE_BLOCK
  else
    STDERR.puts "Error: File not found: #{path}".colorize(:yellow).mode(:bold)
    match
  end
end

loop do
  msg = Readline.readline("> ", true)
  break if msg.nil?
  next if msg.empty?
  break if ["exit", "quit"].includes?(msg)
  next if system_cmd.try_run(msg)

  if modified_data = magic_cmd.try_run(msg, data)
    data = modified_data if modified_data.is_a?(ChatGPT::PostData)
    next
  end

  msg = msg.gsub(/%%{.+?}/) { |match| process_url_substitution(match) }
  msg = msg.gsub(/%{.+?}/) { |match| process_file_substitution(match[2..-2].strip, match) }

  data.messages << {"role" => "user", "content" => msg}
  response = client.send_chat_request(data)
  response_data = JSON.parse(response.body)

  if response.success?
    result = response_data["choices"][0]["message"]["content"]
    data.messages << {"role" => "assistant", "content" => result.to_s}
    puts result.colorize(:green)
  else
    STDERR.puts "Error: #{response.status_code} #{response.status}".colorize(:yellow).mode(:bold)
    STDERR.puts response.body.colorize(:yellow)
    exit 1
  end
end
