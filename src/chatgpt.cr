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
require "./chatgpt/cli/version"
require "./chatgpt/cli/parser"

DEBUG_FLAG      = [false]
API_ENDPOINT = "https://api.openai.com/v1/chat/completions"

struct Lexbor::Node
  def displayble?
    visible? && !object? && !is_tag_noindex?
  end
end

def words(parser)
  parser
    .nodes(:_text)                         # iterate through all TEXT nodes
    .select(&.parents.all?(&.displayble?)) # select only which parents are visible good tag
    .map(&.tag_text)                       # mapping node text
    .reject(&.blank?)                      # reject blanked texts
    .map(&.strip.gsub(/\s{2,}/, " "))      # remove extra spaces
end

data = ChatGPT::PostData.new

ChatGPT::CLI::Parser.new(data).parse

client = ChatGPT::Client.new

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
  if msg.starts_with? "!"
    command = msg[1..-1].strip
    ChatGPT::SystemCommand.new(command).run
    next
  end

  # Run magic command if the message starts with `%`
  if /^%(?!\{|%)/.match msg
    command = msg[1..-1].strip
    ChatGPT::MagicCommand.new(command, data).run
    next
  end

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
