require "../post_data"
require "../config"
require "./version"

module ChatGPT
  class CLI
    class Parser < OptionParser
      getter data : PostData

      def initialize
        @data = PostData.new
        super()
        config = Config.new
        self.banner = 
        <<-BANNER
        
        Program: #{PROGRAM_NAME}
        Version: #{VERSION}
        Source: #{SOURCE_URL}

        Usage: #{PROGRAM_NAME} [options]
        BANNER
        on "-i ID", "--id ID", "Custom system message from configuration file" do |v|
          system_message = config.select_id(v.to_s)
          data.messages << system_message if system_message
        end
        on "-m MODEL", "--model MODEL", "Model name (default: gpt-3.5-turbo)" do |v|
          data.model = v.to_s
        end
        on "-s STR", "--system STR", "System message" do |v|
          data.messages << {"role" => "system", "content" => v.to_s}
        end
        on "-n INT", "How many edits to generate for the input and instruction." do |v|
          data.n = v.to_i? || (STDERR.puts "Error: Invalid number of edits"; exit 1)
        end
        on "-t Float", "--temperature Float", "Sampling temperature between 0 and 2 affects randomness of output." do |v|
          data.temperature = v.to_f? || (STDERR.puts "Error: Invalid temperature"; exit 1)
        end
        on "-p Float", "--top_p Float", "Nucleus sampling considers top_p probability mass for token selection." do |v|
          data.top_p = v.to_f? || (STDERR.puts "Error: Invalid top_p"; exit 1)
        end
        on "-v", "--version", "Show version" do
          puts CLI::VERSION
          exit
        end
        on("-h", "--help", "Show help") { puts self; exit }
      end
    end
  end
end
