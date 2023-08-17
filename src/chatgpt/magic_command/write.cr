module ChatGPT
  class MagicCommand
    def write_to_file(file_name)
      last_response = data.messages.dig?(-1, "content").to_s
      File.write(file_name, last_response)
      puts "Writed to #{file_name}"._colorize(:warning)
      true
    end
  end
end
