module ChatGPT
  class MagicCommand
    def save_data_to_json
      timestamp = Time.local.to_s("%Y%m%d-%H%M%S")
      file_name = "chatgpt-#{timestamp}.json"
      save_data_to_json(file_name)
      true
    end

    def save_data_to_json(file_name)
      File.write(file_name, data.to_pretty_json)
      puts "Saved to #{file_name}"._colorize(:warning)
      true
    end
  end
end
