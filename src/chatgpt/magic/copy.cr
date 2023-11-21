require "easyclip"
require "./base"

module ChatGPT
  class Magic
    class Copy < Base
      def initialize(sender)
        @sender = sender
        @name = "copy, coply n"
        @description = "Copy to clipboard"
        @patterns = [/\Acopy\z/, /\Acopy\s+(\-?\d+)/]
      end

      def run
        run(-1)
        true
      end

      def run(n)
        n = n.to_i
        message = get_message(n) # Defined in Base
        return true if message.nil?
        content = message["content"]
        EasyClip.copy(content)
        true
      end
    end
  end
end
