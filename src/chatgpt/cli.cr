require "option_parser"
require "json"
require "colorize"
require "./utils/colorize_extensions"
{% if env("CHATGPT_READLINE") %}
  require "readline"
{% end %}
require "spinner"

require "crinja"

require "./post_data"
require "./client"
require "./response_data"
require "./system_command"
require "./magic"
require "./substitutor"
require "./cli/version"
require "./cli/parser"

module ChatGPT
  class CLI
    getter post_data : PostData
    getter chat_gpt_client
    getter subcommand : String
    getter options : Hash(String, String | Bool)
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
      @subcommand = command_parser.subcommand
      @options = command_parser.options

      @chat_gpt_client = Client.new
      @system_command_runner = SystemCommand.new
      @magic_command_runner = Magic.new(post_data, key: "%")
      @substitutor = Substitutor.new(@system_command_runner)

      @total_tokens = -1
      @code_blocks = [] of File
    end

    def run
      case @subcommand
      when "i"
        run_interacitively
      when "run"
        run_in_batch
      when "prompts"
        run_prompts
      when "config"
        run_config
      when "help"
        run_help
      when "version"
        run_version
      else
        STDERR.puts "Error: unknown subcommand"._colorize(:warning, :bold)
      end
    end

    def parse_args(args)
      opts = Hash(String, String | Bool | Int32 | Float64).new
      a = Array(String | Bool | Int32 | Float64).new
      key = ""
      args.each do |arg|
        if arg.starts_with?("-") && arg.size == 2 && !arg[1].to_i?
          opts[key] = true unless key.empty?
          next
        end

        if arg.starts_with?("--") && arg.size > 2
          opts[key] = true unless key.empty?
          key = arg[2..-1].gsub("-", "_")
          next
        end

        # value
        if arg.to_i?
          arg = arg.to_i
        elsif arg.to_f?
          arg = arg.to_f
        end

        if key.empty?
          a << arg
        else
          opts[key] = arg
          key = ""
        end
      end
      opts[key] = true unless key.empty?
      return opts, a
    end

    def apply_crinja_rendering(input_msg, opts)
      return Crinja.render(input_msg, opts)
    end

    def read_input_file
      begin
        input_msg = ARGF.gets_to_end
      rescue File::NotFoundError
        STDERR.puts "Error: file not found"._colorize(:warning, :bold)
        exit(1)
      end
      return input_msg
    end

    def run_in_batch
      # FIXME
      # accept only one file
      args = ARGV.class.new
      args = ARGV.pop(ARGV.size - 1) if ARGV.size > 1
      input_msg = read_input_file
      if @options.has_key?("message")
        msg = @options["message"]
        input_msg = "#{input_msg}\n#{msg}" # FIXME placement
      end
      # Enable Crinja if there are arguments
      # FIXME: we should make this more explicit?
      unless args.empty?
        parsed_args, _ = parse_args(args)
        input_msg = apply_crinja_rendering(input_msg, parsed_args)
      end
      add_history(input_msg)
      main_run(input_msg)
    end

    def run_interacitively
      {% if env("CHATGPT_READLINE") %}
        LibReadline.read_history(Config::HISTORY_FILE)
      {% end %}

      input_msg = nil # This is needed to avoid a warning

      loop do
        {% if env("CHATGPT_READLINE") %}
          input_msg = Readline.readline(readline_prompt, true)
          # ctrl + d
          break if input_msg.nil?
        {% else %}
          print(readline_prompt)
          input_msg = gets
          if input_msg.nil?
            # ctrl + d
            puts # Output linebreak
            break
          else
            input_msg = input_msg.chomp
          end
        {% end %}
        # linebreak
        next if input_msg.empty?

        add_history(input_msg)

        # exit or quit
        break if ["exit", "quit"].includes?(input_msg)

        main_run(input_msg)
      end
    end

    def run_prompts
      if @options.fetch("reset", false)
        Config.instance.create_default_prompts
        exit
      end
      Config.instance.prompts.each_with_index do |(k, v), i|
        puts "#{i}\t#{k}"
      end
      exit
    end

    def run_config
      if @options.has_key?("reset") && @options.has_key?("edit")
        STDERR.puts "Error: --reset and --edit cannot be used together"._colorize(:warning, :bold)
        exit(1)
      end
      case @options.fetch("reset", false)
      when true
        Config.instance.create_default_config
        exit
      end
      case @options.fetch("edit", false)
      when true
        Launcher.open_editor(Config::CONFIG_FILE)
        exit
      end
      p! Config::BASE_DIR
      p! Config::CONFIG_FILE
      p! Config::PROMPTS_FILE
      p! Config::POST_DATA_FILE
      p! Config::HISTORY_FILE
      exit
    end

    def run_help
      puts @options["help_message"]
    end

    def run_version
      puts "#{PROGRAM_NAME} #{VERSION}"
      exit
    end

    def main_run(input_msg)
      return true if system_command(input_msg)
      return true if magic_command(input_msg)

      input_msg = substitute_input(input_msg)

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
      result_msg = substitute_output(result_msg)
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
      # .to_s is needed for LibReadline#readline
      "#{post_data.model}:#{ntokens}:#{message_count}> "._colorize(:prompt).to_s
    end

    private def add_history(input_msg)
      File.open(Config::HISTORY_FILE, "a") { |f| f.puts(input_msg) }
    end

    private def substitute_input(input_msg)
      substitutor.substitute(input_msg)
    end

    private def system_command(input_msg)
      system_command_runner.try_run(input_msg)
    end

    private def magic_command(input_msg)
      if magic_command_runner.try_run(input_msg, post_data, response_data, total_tokens)
        @post_data = magic_command_runner.data
        @total_tokens = magic_command_runner.total_tokens
        # magic_command_runner.result
        true
      else
        false
      end
    end

    private def set_envs_from_response(msg)
      set_response_env(msg, "RESPONSE")
      set_code_env(msg, "CODE")
    end

    private def set_response_env(msg, name)
      if ENV.has_key?(name)
        STDERR.puts "Overwriting #{name} environment variable"._colorize(:debug) if ChatGPT.debug?
        STDERR.flush
      end
      ENV[name] = msg
    end

    private def set_code_env(msg, env_prefix)
      code_block_matches = extract_code_blocks(msg)
      # Remove temporary files and environment variables for previous code blocks
      code_blocks.each_with_index do |f, index|
        env_name = "#{env_prefix}#{index}"
        f.delete if File.exists?(f.path)
        ENV.delete(env_name)
      end
      code_blocks.clear
      # Create temporary files and environment variables for new code blocks
      code_block_matches.each_with_index do |match, index|
        env_name = "#{env_prefix}#{index}"
        temp_file = File.tempfile("-chatgpt-codeblock") do |f|
          code = match[2]
          f.print(code)
        end
        code_blocks << temp_file
        check_env(env_name)
        ENV[env_name] = temp_file.path
      end
    end

    private def extract_code_blocks(result_msg)
      # language, code
      result_msg.scan(Config.instance.code_block_pattern)
    end

    private def check_env(name)
      if ENV.has_key?(name) && ChatGPT.debug?
        STDERR.puts "Overwriting #{name} environment variable"._colorize(:debug)
        STDERR.flush
      end
    end

    private def substitute_output(msg)
      colorize_code_blocks(msg)
    end

    def colorize_code_blocks(msg)
      {% if env("CHATGPT_BAT") == "1" %}
        colorize_code_blocks_bat1(msg)
      {% elsif env("CHATGPT_BAT") == "2" %}
        colorize_code_blocks_bat2(msg)
      {% else %}
        msg
      {% end %}
    end

    private def bat_command(lang = "txt", styles = "plain,grid", color = "always")
      lang = "txt" if lang.empty?
      String.build do |s|
        s << "bat"
        s << " -l #{lang}"
        s << " --color #{color}"
        s << " --style #{styles}"
        s << " -"
      end
    end

    private def execute_bat(msg, lang = "txt", styles = "plain,grid", color = "always")
      cmd = bat_command(lang, styles, color)
      ps = Process.new(cmd, shell: true, input: Process::Redirect::Pipe, output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
      stdin = ps.input
      stdout = ps.output
      stderr = ps.error
      stdin.puts(msg)
      stdin.close
      colored_code = stdout.gets_to_end
      error_message = stderr.gets_to_end
      status = ps.wait
      unless status.success?
        error_message._colorize(:warning)
      end
      colored_code
    end

    private def colorize_code_blocks_bat1(msg)
      code_block_matches = extract_code_blocks(msg)
      code_block_matches.each_with_index do |match, index|
        lang = match[1]
        code_block = match[2]
        colored_code = execute_bat(code_block, lang: lang)
        next if colored_code.empty?
        colored_code = "\e[39;49m" + colored_code.chomp
        colored_code = colored_code.append_colorize_start(:chatgpt)
        msg = msg.gsub(match[0], colored_code)
      end
      msg
    end

    private def colorize_code_blocks_bat2(msg)
      execute_bat(msg, lang: "markdown", styles: "plain")
    end

    private def display_errors(response)
      STDERR.puts "Error: #{response.status_code} #{response.status}"._colorize(:warning, :bold)
      STDERR.puts response.body._colorize(:warning)
      STDERR.puts "Hint: try %pop, %edit, %clear, %model or %help"._colorize(:warning, :bold)
    end
  end
end
