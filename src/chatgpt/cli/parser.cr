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
        on "-h", "--help", "Print help" do
          puts self
          exit
        end
      end

      def initialize
        @data = PostData.new
        @interactive = false
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
          @interactive = true
          add_chatgpt_options
        end
        on("run", "Run the program") do
          @interactive = false
          add_chatgpt_options
        end
        on("prompts", "Print all system message IDs and exit") do
          banner = "Usage: #{PROGRAM_NAME} prompts [options]"
          config.prompts.each_with_index do |(k, v), i|
            puts "#{i}\t#{k}"
          end
          exit
        end
        on("config", "Edit config file") do
          banner = "Usage: #{PROGRAM_NAME} config [options]"
          on("--reset", "Reset config file") do
            config.create_default_config
            exit
          end
          on("--edit", "Edit config file") do
            Launcher.open_editor(ChatGPT::Config::CONFIG_FILE)
            exit
          end
        end
        on "version", "Print version info and exit" do
          puts CLI::VERSION
          exit
        end
        on "help", "Print help" do
          puts self
          exit
        end
        unknown_args do |args|
          unless args.empty?
            STDERR.puts "Error: Unknown arguments: #{args.join(" ")}"._colorize(:warning, :bold)
          end
        end
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
