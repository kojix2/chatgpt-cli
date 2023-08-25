require "./base"

module ChatGPT
  class Magic
    class Clear < Base
      def initialize(sender)
        @sender = sender
        @name = "clear"
        @description = "Clear messages and initialize data"
        @patterns = [/\Aclear\z/]
      end

      def run
        data.messages.clear
        puts "Cleared"._colorize(:warning)
        total_tokens = -1
        true
      end
    end
  end
end
