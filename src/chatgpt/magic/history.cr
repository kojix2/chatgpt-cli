require "./base"

module ChatGPT
  class Magic
    class History < Base
      def initialize(sender)
        @sender = sender
        @name = "history"
        @description = "Show history"
        @patterns = [/\Ahistory\z/]
      end

      def run
        open_editor(ChatGPT::Config::HISTORY_FILE)
        true
      end
    end
  end
end
