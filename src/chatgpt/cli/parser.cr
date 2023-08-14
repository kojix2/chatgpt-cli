require "../post_data"
require "../config"
require "./version"

module ChatGPT
  class CLI
    class Parser < OptionParser
      getter data : PostData
      getter interactive : Bool

      def initialize
        @data = PostData.new
        @interactive = true
        super()
        config = Config.instance
        self.banner =
          <<-BANNER
        
          Program: #{PROGRAM_NAME}
          Version: #{VERSION}
          Source: #{SOURCE_URL}

          Usage: #{PROGRAM_NAME} [options]
          BANNER
        on("prompts", "Print all system message IDs and exit") do
          banner = "Usage: #{PROGRAM_NAME} prompts [options]"
          config.prompts.each do |k, v|
            puts k
          end
          exit
        end
        on "-r", "--resume", "Resume the session" do
          load_session(Config::POST_DATA_FILE)
        end
        on "-l FILE", "--load FILE", "Load session from file" do |v|
          load_session(v.to_s)
        end
        on "-m MODEL", "--model MODEL", "Model name [gpt-3.5-turbo]" do |v|
          data.model = v.to_s
        end
        on "-i ID", "--id ID", "ID of the custom system message" do |v|
          system_message = config.select_id(v.to_s)
          data.messages << system_message if system_message
        end
        on "-s STR", "--system STR", "System message" do |v|
          data.messages << {"role" => "system", "content" => v.to_s}
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
        on "-b", "--batch", "Same as --stdout" do
          @interactive = false
        end
        on "-d", "--debug", "Debug mode" do
          DEBUG_FLAG[0] = true
        end
        on "-v", "--version", "Print version info and exit" do
          puts CLI::VERSION
          exit
        end
        on("-h", "--help", "Print help") do
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
