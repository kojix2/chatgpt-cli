module ChatGPT
  class MagicCommand
    def show_total_tokens
      begin
        tokens = response_data.tokens
      rescue ex
        tokens = "Unknown"
      end
      puts "#{tokens}"._colorize(:warning)
      true
    end
  end
end
