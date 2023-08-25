require "./base"

module ChatGPT
  class Magic
    class Resume < Base
      def initialize(sender)
        @sender = sender
        @name = "resume"
        @description = "Resume from auto-saved data"
        @patterns = [/\Aresume\E/]
      end

      def run
        if File.exists?(ChatGPT::Config::POST_DATA_FILE)
          load_data_from_json(ChatGPT::Config::POST_DATA_FILE)
        else
          puts "No saved data"._colorize(:warning)
        end
        total_tokens = -1
        true
      end
    end
  end
end
