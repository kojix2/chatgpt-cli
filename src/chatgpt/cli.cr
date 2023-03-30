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
require "./response_data"
require "./system_command_runner"
require "./magic_command_runner"
require "./input_substitutor"
require "./cli/version"
require "./cli/parser"

module ChatGPT
  class CLI
    getter post_data : PostData
    getter chat_gpt_client
    getter interactive : Bool
    getter system_command_runner
    getter magic_command_runner
    getter substitutor

    property response_data : ResponseData
    property total_tokens : Int32
    property code_blocks : Array(File)

    def initialize
      # Create the base directory if it doesn't exist
      unless Dir.exists?(Config::BASE_DIR)
        Dir.mkdir_p(Config::BASE_DIR)
      end

      command_parser = CLI::Parser.new
      begin
        command_parser.parse
      rescue ex
        STDERR.puts "Error: #{ex.message}".colorize(:yellow).mode(:bold)
      end
      @post_data = command_parser.data
      @response_data = ResponseData.new("{}")
      @interactive = command_parser.interactive

      @chat_gpt_client = Client.new
      @system_command_runner = SystemCommandRunner.new
      @magic_command_runner = MagicCommandRunner.new(post_data, key: "%")
      @substitutor = InputSubstitutor.new(@system_command_runner)

      @total_tokens = -1
      @code_blocks = [] of File
    end

    def run
      if @interactive
        run_interacitively
      else
        run_oneliner
      end
    end

    def run_oneliner
      input_msg = ARGF.gets_to_end
      post_data.add_message("user", input_msg)
      add_history(input_msg)
      run2(input_msg)
    end

    def run_interacitively
      LibReadline.read_history(Config::HISTORY_FILE)
      loop do
        input_msg = Readline.readline(readline_prompt, true)
        break if input_msg.nil?
        next if input_msg.empty?

        add_history(input_msg)

        break if ["exit", "quit"].includes?(input_msg)

        run2(input_msg)
      end
    end

    def run2(input_msg)
      return if system_command_runner.try_run(input_msg)

      if magic_command_runner.try_run(input_msg, post_data, response_data, total_tokens)
        @post_data = magic_command_runner.data
        total_tokens = magic_command_runner.total_tokens
        return if magic_command_runner.next?
      end

      input_msg = substitutors(input_msg)

      post_data.add_message("user", input_msg)
      begin
        response = chat_gpt_client.send_chat_request(post_data)
      rescue ex
        STDERR.puts "Error: #{ex.message}".colorize(:yellow).mode(:bold)
        post_data.messages.pop
        return
      end

      @response_data = ResponseData.new(response.body)

      if response.success?
        result_msg = response_data.assistant_message
        post_data.add_message("assistant", result_msg)
        File.write(Config::POST_DATA_FILE, post_data.to_pretty_json)
        # ENV["RESPONSE"] = result_msg
        extract_code_blocks(result_msg)
        @total_tokens = response_data.total_tokens
        puts result_msg.colorize(:green)
      else
        display_errors(response)
        post_data.messages.pop
      end
    end

    private def message_count
      post_data.count_user_messages + 1
    end

    private def ntokens
      total_tokens < 0 ? "-" : total_tokens
    end

    private def readline_prompt
      "#{post_data.model}:#{ntokens}:#{message_count}> "
    end

    private def add_history(input_msg)
      File.open(Config::HISTORY_FILE, "a") { |f| f.puts(input_msg) }
    end

    private def substitutors(input_msg)
      input_msg = substitutor.stdout(input_msg, /%STDOUT/)
      input_msg = substitutor.stderr(input_msg, /%STDERR/)
      input_msg = substitutor.url(input_msg, /%%\{(.+?)\}/)
      input_msg = substitutor.file(input_msg, /%\{(.+?)\}/)
    end

    private def extract_code_blocks(result_msg)
      matches = result_msg.scan(/```.*?\n(.*?)```/m)
      return if matches.empty?

      code_blocks.each_with_index(1) do |f, idx|
        f.delete
        ENV.delete("CODE#{idx}")
      end
      matches.each_with_index(1) do |match, idx|
        tf = File.tempfile("chatgpt") do |f|
          f.print(match[1])
        end
        code_blocks << tf
        if ENV.has_key?("CODE#{idx}")
          STDERR.puts "Warning: overwriting CODE#{idx} environment variable".colorize(:yellow).mode(:bold)
          STDERR.flush
        end
        ENV["CODE#{idx}"] = tf.path
      end
    end

    private def display_errors(response)
      STDERR.puts "Error: #{response.status_code} #{response.status}".colorize(:yellow).mode(:bold)
      STDERR.puts response.body.colorize(:yellow)
      STDERR.puts "Hint: try %undo, %edit, %clear, %model or %help".colorize(:yellow).mode(:bold)
    end
  end
end
