require "./base"

module ChatGPT
  class Magic
    class Debug < Base
      def initialize(sender)
        @sender = sender
        @name = "debug"
        @description = "Toggle debug mode"
        @patterns = [/\Adebug\z/]
      end

      def run
        DEBUG_FLAG[0] = !DEBUG_FLAG[0]
        puts "Debug mode: #{DEBUG_FLAG[0]}"._colorize(:warning)
        true
      end
    end
  end
end
