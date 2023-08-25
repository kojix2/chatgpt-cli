require "./base"

module ChatGPT
  class MagicCommand
    class Webapp < Base
      def initialize(sender)
        @sender = sender
        @name = "webapp"
        @description = "Open ChatGPT webapp"
        @patterns = [/\Awebapp\E/]
      end

      def run
        # FIXME: do not write url directly
        open_browser("https://chat.openai.com/")
        true
      end
    end
  end
end
