require "./base"

module ChatGPT
  class MagicCommand
    class Shift < Base
      def initialize(sender)
        @sender = sender
        @name = "shift"
        @description = "Remove first message and response"
        @patterns = [/\Ashift\E/, /\Ashift\s+(\d+)/] # FIXME
      end

      def run
        run(1)
        total_tokens = -1
        true
      end

      def run(n)
        number_of_user_messages = data.count_user_messages
        n = [n.to_i, number_of_user_messages].min
        n.times do
          data.messages.shift # query
          data.messages.shift # response
        end
        puts "Shift #{n} messages"._colorize(:warning)
        total_tokens = -1
        true
      end
    end
  end
end
