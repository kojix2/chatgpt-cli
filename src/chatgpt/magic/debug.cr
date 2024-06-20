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
        ChatGPT.debug = !ChatGPT.debug
        puts "Debug mode: #{ChatGPT.debug}"._colorize(:warning)
        true
      end
    end
  end
end
