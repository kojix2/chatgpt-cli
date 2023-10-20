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
        data.messages.each_with_index do |message, i|
          role = message["role"]
          print "[#{i.to_s}]".ljust(3) + "[#{role[0].upcase}]" + " : "
          puts case role
          when "system"
            trancate_message(message["content"])
          when "user"
            trancate_message(message["content"])
          when "assistant"
            trancate_message(message["content"])._colorize(:chatgpt)
          end
        end
        true
      end

      private def trancate_message(str)
        return str if str.size <= chars_to_show

        str[0..chars_to_show] + "..."
      end

      private def chars_to_show
        40
      end
    end
  end
end
