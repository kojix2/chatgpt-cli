require "./base"

module ChatGPT
  class Magic
    class Load < Base
      def initialize(sender)
        @sender = sender
        @name = "load"
        @description = "Load latest saved data from current directory"
        @patterns = [/\Aload\z/, /\Aload\s+(.+)/] # FIXME
      end

      def run
        file_names = Dir.glob("chatgpt-*.json")
        if file_names.empty?
          puts "Error: No saved data"._colorize(:warning, :bold)
          return true
        end
        run(file_names.sort.last)
        true
      end

      def run(file_name)
        begin
          new_data = PostData.from_json(File.read(file_name))
          data = new_data
          puts "Loaded from #{file_name}"._colorize(:warning)
        rescue
          puts "Error: Invalid JSON"._colorize(:warning, :bold)
        end
        total_tokens = -1
        true
      end
    end
  end
end
