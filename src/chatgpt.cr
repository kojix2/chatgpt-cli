# https://platform.openai.com/docs/api-reference/chat

require "option_parser"
require "http/client"
require "json"
require "colorize"
require "readline"
require "spinner"
require "lexbor"

require "./chatgpt/file_extensions"
require "./chatgpt/postdata"
require "./chatgpt/client"
require "./chatgpt/system_command"
require "./chatgpt/magic_command"
require "./chatgpt/webpage_compressor"
require "./chatgpt/cli/version"
require "./chatgpt/cli/parser"

DEBUG_FLAG = [false]

data = ChatGPT::PostData.new

ChatGPT::CLI::Parser.new(data).parse

client = ChatGPT::Client.new

system_cmd = ChatGPT::SystemCommand.new
magic_cmd = ChatGPT::MagicCommand.new(data, key: "%")

loop do
  # Get input from the user
  msg = Readline.readline("> ", true)
  break if msg.nil?

  # Enter
  next if msg.empty?

  # Exit
  break if msg == "exit"
  break if msg == "quit"

  # Run command if the message starts with `!`
  next if system_cmd.try_run(msg)

  # Run magic command if the message starts with `%`
  next if magic_cmd.try_run(msg, data)

  # Replace %%{...} with the contents of the url
  msg = msg.gsub(/%%{.+?}/) do |match|
    url = match[3..-2].strip
    unless url.starts_with? "http"
      url = "https://" + url
    end
    compressed_text = words(Lexbor::Parser.new(HTTP::Client.get(url).body.to_s)).join("|")
    str = <<-CODE_BLOCK
      ### #{url}

      ```
      #{compressed_text}
      ```

      That's all for the #{url}
    CODE_BLOCK
    "\n\n#{str}\n\n"
  end

  # Replace %{...} with the contents of the file
  msg = msg.gsub(/%{.+?}/) do |match|
    path = match[2..-2].strip
    extname = File.extname(path)
    basename = File.basename(path)
    if File.exists?(path)
      str = <<-CODE_BLOCK
        ### #{basename}
  
        ```#{ChatGPT::FILE_EXTENSIONS[extname]}
        #{File.read(path)}
        ```
  
        That's all for the #{basename}
        CODE_BLOCK
      "\n\n#{str}\n\n"
    else
      STDERR.puts "Error: File not found: #{path}".colorize(:yellow).mode(:bold)
      next match
    end
  end

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
