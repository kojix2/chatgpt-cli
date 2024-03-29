require "./base"

module ChatGPT
  class Magic
    class Response < Base
      def initialize(sender)
        @sender = sender
        @name = "response"
        @description = "Show last response in JSON"
        @patterns = [/\Aresponse\z/]
      end

      def run
        File.tempfile("chatgpt-cli", ".json") do |file|
          File.write(file.path, response_data.to_pretty_json)
          open_editor(file.path)
        end.delete
        true
      end
    end
  end
end
