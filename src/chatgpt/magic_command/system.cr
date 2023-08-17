module ChatGPT
  class MagicCommand
    def show_system_messages
      data.messages.each do |msg|
        if msg["role"] == "system"
          puts msg["content"]._colorize(:warning)
        end
      end
      true
    end

    def set_system_messages(message)
      if data.messages.empty?
        data.add_message("system", message)
      elsif data.messages[0]["role"] == "system"
        data.messages[0]["content"] = message
      else
        data.messages.unshift({"role" => "system", "content" => message})
      end
      puts "Set system message to #{message}"._colorize(:warning)
      @total_tokens = -1
      true
    end
  end
end
