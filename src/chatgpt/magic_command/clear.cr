module ChatGPT
  class MagicCommand
    def clear_messages
      data.messages.clear
      puts "Cleared"._colorize(:warning)
      @total_tokens = -1
      true
    end
  end
end
