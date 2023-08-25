require "./base"

module ChatGPT
  class MagicCommand
    class Save < Base
      def initialize(sender)
        @sender = sender
        @name = "save"
        @description = "Save data to chatgpt-<timestamp>.json"
        @patterns = [/\Asave\E/, /\Asave\s+(.+)/] # FIXME
      end

      def run
        timestamp = Time.local.to_s("%Y%m%d-%H%M%S")
        file_name = "chatgpt-#{timestamp}.json"
        run(file_name)
        true
      end

      def run(file_name)
        File.write(file_name, data.to_pretty_json)
        puts "Saved to #{file_name}"._colorize(:warning)
        true
      end
    end
  end
end
