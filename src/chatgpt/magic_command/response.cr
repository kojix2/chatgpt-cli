module ChatGPT
  class MagicCommand
    def show_response_json
      File.tempfile("chatgpt-cli", ".json") do |file|
        File.write(file.path, response_data.to_pretty_json)
        open_editor(file.path)
      end.delete
      true
    end
  end
end
