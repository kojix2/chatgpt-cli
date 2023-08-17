require "html"

module ChatGPT
  class HtmlGenerator
    class HtmlGenerationError < Exception; end

    class Message
      @message : Hash(String, String)

      def initialize(@message)
      end

      def role
        @message["role"]
      end

      def content
        HTML.escape(@message["content"])
      end

      def avatar_class
        case role
        when "user", "system" # FIXME system
          "avatar human"
        when "assistant"
          "avatar gpt"
        else
          raise HtmlGenerationError.new("Unknown role: #{role}")
        end
      end

      def direction
        case role
        when "user", "system" # FIXME system
          "from"
        when "assistant"
          "to"
        else
          raise HtmlGenerationError.new("Unknown role: #{role}")
        end
      end

      def avatar_image
        raise NotImplementedError
      end
    end
  end
end
