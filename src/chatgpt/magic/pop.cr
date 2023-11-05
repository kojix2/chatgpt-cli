require "./base"

module ChatGPT
  class Magic
    class Undo < Base
      def initialize(sender)
        @sender = sender
        @name = "pop"
        @description = "Remove last message and response"
        @patterns = [/\Apop\z/, /\Apop\s+(\d+)/]
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
