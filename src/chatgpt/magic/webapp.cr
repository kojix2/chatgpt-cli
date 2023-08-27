require "./base"

module ChatGPT
  class Magic
    class Webapp < Base
      def initialize(sender)
        @sender = sender
        @name = "webapp"
        @description = "Open ChatGPT webapp"
        @patterns = [/\Awebapp\z/]
      end

      def run
        # FIXME: do not write url directly
        open_browser(Client::WEB_APP_URL)
        true
      end
    end
  end
end
