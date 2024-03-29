require "./base"

module ChatGPT
  class Magic
    class Cd < Base
      def initialize(sender)
        @sender = sender
        @name = "cd <path>"
        @description = "Change current directory"
        @patterns = [/\Acd\z/, /^cd\s+(.+)/]

        @original_dir = Dir.current
      end

      def run
        run(@original_dir)
      end

      def run(path)
        begin
          Dir.cd(path)
          puts "#{Dir.current}"._colorize(:warning)
        rescue e
          puts "Invalid path"._colorize(:warning)
        end
        true
      end
    end
  end
end
