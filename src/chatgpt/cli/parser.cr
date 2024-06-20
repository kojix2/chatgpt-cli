require "../post_data"
require "../config"
require "./version"

module ChatGPT
  class CLI
    class Parser < OptionParser
      getter data : PostData
      getter subcommand : String
      getter options : Hash(String, String | Bool)

      macro add_chatgpt_options
        on "-r", "--resume", "Resume the session" do
          load_session(Config::POST_DATA_FILE)
        end
        on "-s STR", "--system STR", "System message" do |v|
          data.messages << {"role" => "system", "content" => v.to_s}
        end
        on "-p ID", "--ap ID", "Awesome-Chatgpt-Prompts" do |v|
          system_message = config.select_id(v.to_s)
          data.messages << system_message if system_message
        end
        on "-M MODEL", "--model MODEL", "Model name [gpt-4o]" do |v|
          data.model = v.to_s
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
          ChatGPT.debug = true
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

      def parse(args = ARGV)
        if args.empty?
          args.unshift("run")
        elsif args[0] == "--version"
          args = ["version"]
        elsif (args[0] == "--help" || args[0] == "-h")
          args = ["help"]
          # Assume "run" if no subcommand is given
        elsif !@handlers.has_key?(args[0])
          args.unshift("run")
        end
        super(args)
      end

      def initialize
        @data = PostData.new
        @subcommand = ""
        @options = {} of String => String | Bool
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
          add_banner
          add_chatgpt_options
          add_help_option
          # unknown_args { }
          add_unknown_args(0)
        end
        on("run", "Run the program") do
          @subcommand = "run"
          add_banner
          add_chatgpt_options
          on("-m MSG", "--message MSG", "Add a message to the input file/stream") { |s| @options["input"] = s }
          on("-i", "--interactive", "Interactive mode") { @subcommand = "i" }
          add_help_option
          unknown_args { }
          # add_unknown_args(1)
        end
        on("prompts", "Print all system message IDs and exit") do
          @subcommand = "prompts"
          add_banner
          on("--reset", "Reset prompts file") { @options["reset"] = true }
          on("--edit", "Edit prompts file") { @options["edit"] = true }
          add_help_option
          add_unknown_args(1)
        end
        on("config", "Edit config file") do
          @subcommand = "config"
          add_banner
          on("--reset", "Reset config file") { @options["reset"] = true }
          on("--edit", "Edit config file") { @options["edit"] = true }
          add_help_option
          add_unknown_args(0)
        end
        on "version", "Print version info and exit" do
          @subcommand = "version"
          add_unknown_args(0)
        end
        help_message = self.to_s
        on "help", "Print this help screen" do
          @subcommand = "help"
          add_unknown_args(0)
          @options["help_message"] = help_message
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
