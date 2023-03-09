# https://platform.openai.com/docs/api-reference/chat

require "option_parser"
require "http/client"
require "json"
require "colorize"
require "readline"
require "spinner"

require "./file_extensions"

PROGRAM_VERSION = "0.1.0"
DEBUG_FLAG = [false]

struct PostData
  include JSON::Serializable
  property model : String
  property messages : Array(Hash(String, String))
  property temperature : Float64
  property top_p : Float64
  property n : Int32

  def initialize
    @model = "gpt-3.5-turbo"
    @messages = [] of Hash(String, String)
    @n = 1
    @temperature = 1.0
    @top_p = 1.0
  end
end

data = PostData.new

# Parse command line options
OptionParser.parse do |parser|
  parser.banner = "Usage: #{PROGRAM_NAME} [options]"
  parser.on "-n INT", "How many edits to generate for the input and instruction." do |v|
    data.n = v.to_i? || (STDERR.puts "Error: Invalid number of edits"; exit 1)
  end
  parser.on "-t Float", "--temperature Float", "Sampling temperature between 0 and 2 affects randomness of output." do |v|
    data.temperature = v.to_f? || (STDERR.puts "Error: Invalid temperature"; exit 1)
  end
  parser.on "-p Float", "--top_p Float", "Nucleus sampling considers top_p probability mass for token selection." do |v|
    data.top_p = v.to_f? || (STDERR.puts "Error: Invalid top_p"; exit 1)
  end
  parser.on "-v", "--version", "Show version" do
    puts PROGRAM_VERSION
    exit
  end
  parser.on("-h", "--help", "Show help") { puts parser; exit }
end

url = "https://api.openai.com/v1/chat/completions"
api_key = ENV["OPENAI_API_KEY"]
headers = HTTP::Headers{
  "Authorization" => "Bearer #{api_key}",
  "Content-Type"  => "application/json",
}

def send_chat_request(url, data, headers)
  STDERR.puts data.pretty_inspect.colorize(:dark_gray) if DEBUG_FLAG[0]
  spinner_text = "ChatGPT".colorize(:green)
  sp = Spin.new(0.2, Spinner::Charset[:pulsate2], spinner_text, output: STDERR)
  sp.start
  response = HTTP::Client.post(url, body: data.to_json, headers: headers)
  sp.stop
  response
end

def run_system_command(command)
  output = `#{command}`
  if $?.success?
    puts output.colorize(:yellow)
  else
    STDERR.puts "Error: Command failed: #{command}".colorize(:yellow).mode(:bold)
    STDERR.puts output.colorize(:yellow)
  end
end

def run_magic_command(command, data)
  case command
  when "debug"
    DEBUG_FLAG[0] = !DEBUG_FLAG[0]
    puts "Debug mode: #{DEBUG_FLAG[0]}".colorize(:yellow)
  when "saveall"
    File.write("chatgpt.json", data.to_json)
    puts "Saved to chatgpt.json".colorize(:yellow)
  when /save\s+(.+)/
    File.write($1, data.messages[-1]["content"])
    puts "Saved to #{$1}".colorize(:yellow)
  else
    STDERR.puts "Error: Unknown magic command: #{command}".colorize(:yellow).mode(:bold)
  end
end

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
    msg = run_system_command(command)
    next
  end

  # Run magic command if the message starts with `%`
  if msg.starts_with? "%"
    command = msg[1..-1].strip
    msg = run_magic_command(command, data)
    next
  end

  # Replace #{...} with the contents of the file
  msg = msg.gsub(/\#{.+?}/) do |match|
    path = match[2..-2].strip
    extname = File.extname(path)
    basename = File.basename(path)
    if File.exists?(path)
      str = <<-CODE_BLOCK
      ### #{basename}

      ```#{FILE_EXTENSIONS[extname]}
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

  response = send_chat_request(url, data, headers)
  response_data = JSON.parse(response.body)

  if response.status.success?
    result = response_data["choices"][0]["message"]["content"]
    data.messages << {"role" => "assistant", "content" => result.to_s}
    puts result.colorize(:green)
  else
    STDERR.puts "Error: #{response.status_code} #{response.status}".colorize(:yellow).mode(:bold)
    STDERR.puts response.body.colorize(:yellow)
    exit 1
  end
end
