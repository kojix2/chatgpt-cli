require "option_parser"
require "http/client"
require "json"
require "colorize"
require "readline"
require "spinner"
require "lexbor"

require "./file_extensions"
require "./post_data"
require "./client"
require "./system_command_runner"
require "./magic_command_runner"
require "./input_substitutor"
require "./cli/version"
require "./cli/parser"

module ChatGPT
  class CLI
    getter post_data : PostData
    getter chat_gpt_client
    getter system_command_runner
    getter magic_command_runner
    getter substitutor

    def initialize
      # Create the base directory if it doesn't exist
      unless Dir.exists?(Config::BASE_DIR)
        Dir.mkdir_p(Config::BASE_DIR)
      end
      # FIXME
      File.open(Config::RESPONSE_FILE, "w") { |f| f.print("") }

      command_parser = CLI::Parser.new
      begin
        command_parser.parse
      rescue ex
        STDERR.puts "Error: #{ex.message}".colorize(:yellow).mode(:bold)
      end
      @post_data = command_parser.data

      @chat_gpt_client = Client.new
      @system_command_runner = SystemCommandRunner.new
      @magic_command_runner = MagicCommandRunner.new(post_data, key: "%")
      @substitutor = InputSubstitutor.new(@system_command_runner)
    end

    def run
      total_tokens = 0
      message_count = 0 
      loop do
        message_count = post_data.messages.count { |msg| msg["role"] == "user" } + 1
        input_msg = Readline.readline("#{post_data.model}:#{total_tokens}:#{message_count}> ", true)
        break if input_msg.nil?
        next if input_msg.empty?

        File.open(Config::HISTORY_FILE, "a") { |f| f.puts(input_msg) }
        
        break if ["exit", "quit"].includes?(input_msg)

        next if system_command_runner.try_run(input_msg)

        if modified_post_data = magic_command_runner.try_run(input_msg, post_data)
          @post_data = modified_post_data if modified_post_data.is_a?(PostData)
          next
        end
        input_msg = substitutor.stdout(input_msg, /%STDOUT/)
        input_msg = substitutor.stderr(input_msg, /%STDERR/)
        input_msg = substitutor.url(input_msg, /%%\{(.+?)\}/)
        input_msg = substitutor.file(input_msg, /%\{(.+?)\}/)

        post_data.messages << {"role" => "user", "content" => input_msg}
        response = chat_gpt_client.send_chat_request(post_data)
        response_data = JSON.parse(response.body)
        File.write(Config::RESPONSE_FILE, response_data.to_pretty_json)

        if response.success?
          result_msg = response_data.dig("choices", 0, "message", "content")
          post_data.messages << {"role" => "assistant", "content" => result_msg.to_s}
          File.write(Config::POST_DATA_FILE, post_data.to_pretty_json)
          total_tokens = response_data.dig("usage", "total_tokens").to_s.to_i
          puts result_msg.colorize(:green)
        else
          STDERR.puts "Error: #{response.status_code} #{response.status}".colorize(:yellow).mode(:bold)
          STDERR.puts response.body.colorize(:yellow)
          STDERR.puts "Hint: try %undo, %edit, %clear, %model or %help".colorize(:yellow).mode(:bold)
          post_data.messages.pop
        end
      end
    end
  end
end
