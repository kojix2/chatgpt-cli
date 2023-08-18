require "option_parser"
require "json"
require "colorize"
require "./utils/colorize_extensions"
require "readline"
require "spinner"

require "./post_data"
require "./client"
require "./response_data"
require "./system_command"
require "./magic_command"
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

    getter response_data : ResponseData
    getter total_tokens : Int32
    getter code_blocks : Array(File)

    def initialize
      # Create the base directory if it doesn't exist
      unless Dir.exists?(Config::BASE_DIR)
        Dir.mkdir_p(Config::BASE_DIR)
      end

      command_parser = CLI::Parser.new
      begin
        command_parser.parse
      rescue ex
        STDERR.puts "Error: #{ex.message}"._colorize(:warning, :bold)
      end
      @post_data = command_parser.data
      @response_data = ResponseData.new("{}")
      @interactive = command_parser.interactive

      @chat_gpt_client = Client.new
      @system_command_runner = SystemCommand.new
      @magic_command_runner = MagicCommand.new(post_data, key: "%")
      @substitutor = InputSubstitutor.new(@system_command_runner)

      @total_tokens = -1
      @code_blocks = [] of File
    end

    def run
      if @interactive
        run_interacitively
      else
        run_in_batch
      end
    end

    def run_in_batch
      input_msg = ARGF.gets_to_end
      add_history(input_msg)
      main_run(input_msg)
    end

    def run_interacitively
      LibReadline.read_history(Config::HISTORY_FILE)
      loop do
        input_msg = Readline.readline(readline_prompt, true)
        # ctrl + d
        break if input_msg.nil?
        # linebreak
        next if input_msg.empty?

        add_history(input_msg)

        # exit or quit
        break if ["exit", "quit"].includes?(input_msg)

        main_run(input_msg)
      end
    end

    def main_run(input_msg)
      return true if system_command(input_msg)
      return true if magic_command(input_msg)

      input_msg = substitute(input_msg)

      post_data.add_message("user", input_msg)

      begin
        response = chat_gpt_client.send_chat_request(post_data)
      rescue ex
        STDERR.puts "Error: #{ex.message}"._colorize(:warning, :bold)
        post_data.messages.pop
        return false
      end

      unless response.success?
        display_errors(response)
        post_data.messages.pop
        return false
      end

      @response_data = ResponseData.new(response.body)
      result_msg = response_data.assistant_message
      post_data.add_message("assistant", result_msg)
      File.write(Config::POST_DATA_FILE, post_data.to_pretty_json)

      set_envs_from_response(result_msg)
      @total_tokens = response_data.total_tokens
      puts result_msg._colorize(:chatgpt)
      return true
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

    private def substitute(input_msg)
      config = Config.instance
      input_msg = substitutor.stdout(input_msg, config.stdout_regex)
      input_msg = substitutor.stderr(input_msg, config.stderr_regex)
      input_msg = substitutor.command(input_msg, config.command_regex)
      input_msg = substitutor.url(input_msg, config.url_regex)
      input_msg = substitutor.file(input_msg, config.file_regex)
    end

    private def system_command(input_msg)
      system_command_runner.try_run(input_msg)
    end

    private def magic_command(input_msg)
      # FIXME
      return false unless magic_command_runner.try_run(input_msg, post_data, response_data, total_tokens)

      @post_data = magic_command_runner.data
      @total_tokens = magic_command_runner.total_tokens

      magic_command_runner.next?
    end

    private def set_envs_from_response(msg)
      set_response_env(msg, "RESPONSE")
      extract_code_blocks(msg)
    end

    private def set_response_env(msg, name)
      if ENV.has_key?(name)
        STDERR.puts "Overwriting #{name} environment variable"._colorize(:debug) if debug_mode?
        STDERR.flush
      end
      ENV[name] = msg
    end

    private def extract_code_blocks(result_msg)
      code_block_matches = result_msg.scan(/```.*?\n(.*?)```/m)
      return if code_block_matches.empty?

      env_prefix = "CODE" # FIXIT make this configurable
      # Remove temporary files and environment variables for previous code blocks
      code_blocks.each_with_index(1) do |f, index|
        env_name = "#{env_prefix}#{index}"
        f.delete if File.exists?(f.path)
        ENV.delete(env_name)
      end
      code_blocks.clear
      # Create temporary files and environment variables for new code blocks
      code_block_matches.each_with_index(1) do |match, index|
        env_name = "#{env_prefix}#{index}"
        temp_file = File.tempfile("chatgpt-codeblock") do |f|
          code = match[1]
          f.print(code)
        end
        code_blocks << temp_file
        check_env(env_name)
        ENV[env_name] = temp_file.path
      end
    end

    private def check_env(name)
      if ENV.has_key?(name) && debug_mode?
        STDERR.puts "Overwriting #{name} environment variable"._colorize(:debug)
        STDERR.flush
      end
    end

    private def display_errors(response)
      STDERR.puts "Error: #{response.status_code} #{response.status}"._colorize(:warning, :bold)
      STDERR.puts response.body._colorize(:warning)
      STDERR.puts "Hint: try %undo, %edit, %clear, %model or %help"._colorize(:warning, :bold)
    end

    private def debug_mode?
      DEBUG_FLAG[0]
    end
  end
end
