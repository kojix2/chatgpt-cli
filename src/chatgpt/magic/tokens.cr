require "./base"

module ChatGPT
  class Magic
    class Tokens < Base
      def initialize(sender)
        @sender = sender
        @name = "tokens"
        @description = "Show total tokens used"
        @patterns = [/\Atokens\E/]
      end

      def run
        begin
          tokens = response_data.tokens
        rescue ex
          tokens = "Unknown"
        end
        puts "#{tokens}"._colorize(:warning)
        true
      end
    end
  end
end
