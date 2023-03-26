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
require "./chatgpt/system_command_runner"
require "./chatgpt/magic_command_runner"
require "./chatgpt/input_substitutor"
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
system_command_runner = ChatGPT::SystemCommandRunner.new
magic_command_runner = ChatGPT::MagicCommandRunner.new(post_data, key: "%")

loop do
  input_msg = Readline.readline("#{post_data.model}> ", true)
  break if input_msg.nil?
  next if input_msg.empty?
  break if ["exit", "quit"].includes?(input_msg)

  next if system_command_runner.try_run(input_msg)

  if modified_post_data = magic_command_runner.try_run(input_msg, post_data)
    post_data = modified_post_data if modified_post_data.is_a?(ChatGPT::PostData)
    next
  end

  input_msg = input_msg.gsub(/%%{.+?}/) do |url_match|
    ChatGPT::InputSubstitutor.url_substitution(url_match)
  end
  input_msg = input_msg.gsub(/%{.+?}/) do |file_match|
    ChatGPT::InputSubstitutor.file_substitution(file_match)
  end
  input_msg = input_msg.gsub(/%STDOUT/) do |stdout_match|
    ChatGPT::InputSubstitutor.stdout_substitution(
      stdout_match,
      system_command_runner.last_command, system_command_runner.last_stdout
    )
  end
  input_msg = input_msg.gsub(/%STDERR/) do |stderr_match|
    ChatGPT::InputSubstitutor.stderr_substitution(
      stderr_match,
      system_command_runner.last_command, system_command_runner.last_stderr
    )
  end

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
    post_data.messages.pop
  end
end
