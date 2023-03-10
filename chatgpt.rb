require 'optparse'
require 'openai'
require 'json'
require 'colorize'
require 'readline'
require 'tty-spinner'

eval(File.read('file_extensions.cr'))

PROGRAM_NAME    = 'ChatGPT'
PROGRAM_VERSION = '0.1.0'
DEBUG_FLAG      = [false]

parameters = {
  model: 'gpt-3.5-turbo',
  messages: [],
  n: 1,
  temperature: 1.0,
  top_p: 1.0
}

# Parse command line options
OptionParser.new do |parser|
  parser.banner = "Usage: #{PROGRAM_NAME} [options]"
  parser.on '-s STR', '--system STR', 'System message' do |v|
    parameters[:messages] << { 'role' => 'system', 'content' => v.to_s }
  end
  parser.on '-n INT', 'How many edits to generate for the input and instruction.' do |v|
    parameters[:n] = v.to_i?
  end
  parser.on '-t Float', '--temperature Float',
            'Sampling temperature between 0 and 2 affects randomness of output.' do |v|
    parameters[:temperature] = v.to_f?
  end
  parser.on '-p Float', '--top_p Float', 'Nucleus sampling considers top_p probability mass for token selection.' do |v|
    parameters[:top_p] = v.to_f?
  end
  parser.on '-d', '--debug', 'Debug mode' do
    DEBUG_FLAG[0] = true
  end
  parser.on '-v', '--version', 'Show version' do
    puts PROGRAM_VERSION
    exit
  end
  parser.on('-h', '--help', 'Show help') do
    puts parser
    exit
  end
end.parse!

if api_key = ENV['OPENAI_API_KEY']
  client = OpenAI::Client.new(access_token: api_key)
else
  output_error 'Error: OPENAI_API_KEY is not set'
  exit 1
end

def send_chat_request(client, parameters)
  warn parameters.pretty_inspect.colorize(:dark_gray) if DEBUG_FLAG[0]

  spinner = TTY::Spinner.new(hide_cursor: true, clear: true)
  spinner.auto_spin
  begin
    response = client.chat(parameters: parameters)
  ensure
    spinner.stop
  end

  warn response.pretty_inspect.colorize(:dark_gray) if DEBUG_FLAG[0]

  response
end

def run_system_command(command)
  output = `#{command}`
  if $?.success?
    puts output.colorize(:yellow)
  else
    output_error "Error: Command failed: #{command}"
    output_error output.colorize(:yellow)
  end
end

def run_magic_command(command, data)
  case command
  when 'clear'
    data[:messages].clear
  when 'debug'
    DEBUG_FLAG[0] = !DEBUG_FLAG[0]
  when /save\s+(.+)/
    File.write(Regexp.last_match(1), data.messages[-1]['content'])
    puts "Saved to #{Regexp.last_match(1)}".colorize(:yellow)
  else
    output_error "Error: Unknown magic command: #{command}"
  end
end

loop do
  # Get input from the user
  msg = Readline.readline('> ', true)
  break if msg.nil?

  # Enter
  next if msg.empty?

  # Exit
  break if msg == 'exit'
  break if msg == 'quit'

  # Run command if the message starts with !
  if msg.start_with? '!'
    command = msg[1..-1].strip
    msg = run_system_command(command)
    next
  end

  # Run magic command if the message starts with %
  if msg.start_with? '%'
    command = msg[1..-1].strip
    msg = run_magic_command(command, parameters)
    next
  end

  # Replace # {...} with the contents of the file
  msg = msg.gsub(/%{.+?}/) do |match|
    path = match[2..-2].strip
    extname = File.extname(path)
    basename = File.basename(path)
    if File.exist?(path)
      str = <<-CODE_BLOCK
        ### #{basename}

        ruby

          ```#{FILE_EXTENSIONS[extname]}
          #{File.read(path)}
          ```

          That's all for the #{basename}
      CODE_BLOCK
      "\n\n#{str}\n\n"
    else
      output_error "Error: File not found: #{path}"
      next match
    end
  end

  parameters[:messages] << { 'role' => 'user', 'content' => msg }

  begin
    response = send_chat_request(client, parameters)
    result = response.dig('choices', 0, 'message', 'content')
    parameters[:messages] << { 'role' => 'assistant', 'content' => result.to_s }
    puts result.colorize(:green)
  rescue StandardError => e
    output_error e.message
    output_error 'Error: Failed to send chat request'
    exit 1
  end
end

private

def output_error(message)
  warn message.colorize(color: :yellow, mode: :bold)
end
