require "./base"

module ChatGPT
  class Magic
    class Html < Base
      def initialize(sender)
        @sender = sender
        @name = "html"
        @description = "Show data in the browser"
        @patterns = [/\Ahtml\E/, /\Ahtml\s+(.+)/]
      end

      def run
        html = HtmlGenerator.new(data).to_s
        timestamp = Time.local.to_s("%Y%m%d-%H%M%S")
        file_name = "chatgpt-#{timestamp}.html"
        run(file_name)
      end

      def run(file_name)
        html = HtmlGenerator.new(data).to_s
        File.write(file_name, html)
        open_browser(file_name)
        # file.delete   # FIXME: delete file
        true
      end
    end
  end
end
