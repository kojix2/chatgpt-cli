require "./base"

module ChatGPT
  class Magic
    class Write < Base
      def initialize(sender)
        @sender = sender
        @name = "write <file_name> or w <file_name>"
        @description = "Write last message to <file_name>"
        @patterns = [/\A[write,w]\s+(.+)/] # FIXME
      end

      def run(file_name)
        last_response = data.messages.dig?(-1, "content").to_s
        File.write(file_name, last_response)
        puts "Written to #{file_name}"._colorize(:warning)
        true
      end
    end
  end
end
