module ChatGPT
  class CLI
    def initialize
      # Create the base directory if it doesn't exist
      unless Dir.exists?(Config::BASE_DIR)
        Dir.mkdir_p(Config::BASE_DIR)
      end
      # FIXME
      File.open(Config::RESPONSE_FILE, "w") { |f| f.print("") }
    end
    
    def self.run
      cli = CLI.new

      command_parser = CLI::Parser.new
      command_parser.parse
      post_data = command_parser.data

      gpt_client = Client.new
      system_command_runner = SystemCommandRunner.new
      magic_command_runner = MagicCommandRunner.new(post_data, key: "%")

      # ... (rest of the code remains unchanged)
    end
  end
end

```