require "./base"

module ChatGPT
  class Magic
    class List < Base
      def initialize(sender)
        @sender = sender
        @name = "list"
        @description = "Show chat summaries"
        @patterns = [/\Alist\z/, /\Alist\[(\-?\d+)\]/]
      end

      def run(n)
        n = n.to_i
        msg_count = data.messages.size
        if (n >= msg_count || n < -msg_count)
          puts "Invalid index: #{n}"._colorize(:warning)
          return false
        end
        message = data.messages[n]
        role = message["role"]
        puts case role
        when "system"
          message["content"]
        when "user"
          message["content"]
        when "assistant"
          message["content"]._colorize(:chatgpt)
        end
        true
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
        {% unless env("CHATGPT_NO_READLINE") %}
          Readline.get_screen_size[1] - 20
        {% else %}
          40
        {% end %}
      end
    end
  end
end
