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
        tempfile = File.tempfile("chatgpt") do |f|
          f.print(message.fetch("content", ""))
        end
        copy_to_clipboard(tempfile.path)
        tempfile.delete
        true
      end

      private def copy_to_clipboard(path)
        {% if flag?(:darwin) %}
          system "pbcopy < #{path}"
        {% elsif flag?(:unix) %}
          system "xsel -ib < #{path}"
        {% elsif flag?(:win32) %}
          system "clip < #{path}"
        {% end %}
      end
    end
  end
end
