require "./base"

module ChatGPT
  class MagicCommand
    class Undo < Base
      def initialize(sender)
        @sender = sender
        @name = "undo"
        @description = "Undo last message and response"
        @patterns = [/\Aundo\E/, /\Aundo\s+(\d+)/]
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
          data.messages.pop # response
          data.messages.pop # query
        end
        puts "Undo #{n == 1 ? "last" : n} messages"._colorize(:warning)
        total_tokens = -1
        true
      end
    end
  end
end
