require "../post_data"
require "../config"
require "./version"

module ChatGPT
  class CLI
    class Parser < OptionParser
      getter data : PostData
      getter interactive : Bool

      macro add_chatgpt_options
        on "-m MODEL", "--model MODEL", "Model name [gpt-3.5-turbo]" do |v|
          data.model = v.to_s
        end
        on "-r", "--resume", "Resume the session" do
          load_session(Config::POST_DATA_FILE)
        end
        on "-s STR", "--system STR", "System message" do |v|
          data.messages << {"role" => "system", "content" => v.to_s}
        end
        on "-i ID", "--id ID", "ID of the custom system message" do |v|
          system_message = config.select_id(v.to_s)
          data.messages << system_message if system_message
        end
        on "-E INT", "Number of edits to generate [1]" do |v|
          data.n = v.to_i? || (STDERR.puts "Error: Invalid number of edits"; exit 1)
        end
        on "-T Float", "--temperature Float", "Sampling temperature to use [1.0]" do |v|
          data.temperature = v.to_f? || (STDERR.puts "Error: Invalid temperature"; exit 1)
        end
        on "-P Float", "--top_p Float", "Probability threshold of nucleus sampling [1.0]" do |v|
          data.top_p = v.to_f? || (STDERR.puts "Error: Invalid top_p"; exit 1)
        end
        on "-l FILE", "--load FILE", "Load session from file" do |v|
          load_session(v.to_s)
        end
        on "-d", "--debug", "Debug mode" do
          DEBUG_FLAG[0] = true
        end
      end

      macro add_banner
        self.banner = "Usage: #{PROGRAM_NAME} #{@subcommand} [options]"
      end

      macro add_help_option
        on "-h", "--help", "Print a help message" do
          puts self
          exit
        end
      end

      macro add_unknown_args(allow_args_size = -1)
        unknown_args do |args|
          {% if allow_args_size > -1 %}
            next if args.size <= {{allow_args_size}}
          {% end %}
          unless args.empty?
            STDERR.puts "Error: Unknown arguments: #{args.join(" ")}"._colorize(:warning, :bold)
          end
          STDERR.puts self
          exit 1
        end
      end

      def initialize
        @data = PostData.new
        @interactive = true
        @subcommand = ""
        super()
        config = Config.instance
        self.banner =
          <<-BANNER
        
          Program: #{PROGRAM_NAME}
          Version: #{VERSION}
          Source: #{SOURCE_URL}

          Usage: #{PROGRAM_NAME} [options]
          BANNER
        on("i", "Interactive mode") do
          @subcommand = "i"
          @interactive = true
          add_banner
          add_chatgpt_options
          add_help_option
          add_unknown_args(0)
        end
        on("run", "Run the program") do
          @subcommand = "run"
          @interactive = false
          add_banner
          add_chatgpt_options
          add_help_option
          add_unknown_args(1)
        end
        on("prompts", "Print all system message IDs and exit") do
          @subcommand = "prompts"
          add_banner
          config.prompts.each_with_index do |(k, v), i|
            puts "#{i}\t#{k}"
          end
          add_help_option
          add_unknown_args
          exit
        end
        on("config", "Edit config file") do
          @subcommand = "config"
          add_banner
          on("--reset", "Reset config file") do
            config.create_default_config
            exit
          end
          on("--edit", "Edit config file") do
            Launcher.open_editor(ChatGPT::Config::CONFIG_FILE)
            exit
          end
          add_help_option
          add_unknown_args
        end
        on "version", "Print version info and exit" do
          @subcommand = "version"
          puts CLI::VERSION
          exit
        end
        add_unknown_args
      end

      def load_session(filename)
        begin
          @data = PostData.from_json(File.read(filename))
        rescue
          STDERR.puts "Error: Loading session failed (#{filename})"
        end
      end
    end
  end
end
