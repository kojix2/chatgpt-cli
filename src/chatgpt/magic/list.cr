require "./base"

module ChatGPT
  class Magic
    class List < Base
      def initialize(sender)
        @sender = sender
        @name = "list"
        @description = "Show chat summaries"
        @patterns = [/\Alist\z/]
      end

      def run
        data.messages.each do |message|
          case message["role"]
          when "system"
            puts message["content"]
          when "user"
            puts message["content"]
          when "assistant"
            puts message["content"]._colorize(:chatgpt)
          end
        end
        true
      end
    end
  end
end
