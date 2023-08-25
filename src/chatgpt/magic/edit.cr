require "./base"

module ChatGPT
  class MagicCommand
    class Edit < Base
      def initialize(sender)
        @sender = sender
        @name = "edit"
        @description = "Show or edit data in JSON"
        @patterns = [/\Aedit\E/]
      end

      def run
        new_data = data
        File.tempfile("chatgpt-cli", ".json") do |file|
          File.write(file.path, data.to_pretty_json)
          open_editor(file.path)
          begin
            new_data = PostData.from_json(File.read(file.path))
            puts "Saved"._colorize(:warning)
          rescue
            puts "Error: Invalid JSON"._colorize(:warning, :bold)
          end
        end.delete
        data = new_data
        total_tokens = -1
        true
      end
    end
  end
end
