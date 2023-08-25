require "./base"

module ChatGPT
  class Magic
    class Config < Base
      def initialize(sender)
        @sender = sender
        @name = "config"
        @description = "Edit config file"
        @patterns = [/\Aconfig\E/]
      end

      def run
        open_editor(ChatGPT::Config::CONFIG_FILE)
        true
      end
    end
  end
end
