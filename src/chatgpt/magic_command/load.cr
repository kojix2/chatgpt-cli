module ChatGPT
  class MagicCommand
    def load_data_from_json
      file_names = Dir.glob("chatgpt-*.json")
      if file_names.empty?
        puts "Error: No saved data"._colorize(:warning, :bold)
        return true
      end
      load_data_from_json(file_names.sort.last)
      true
    end

    def load_data_from_json(file_name)
      begin
        new_data = PostData.from_json(File.read(file_name))
        @data = new_data
        puts "Loaded from #{file_name}"._colorize(:warning)
      rescue
        puts "Error: Invalid JSON"._colorize(:warning, :bold)
      end
      @total_tokens = -1
      true
    end
  end
end
