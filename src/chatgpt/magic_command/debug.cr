module ChatGPT
  class MagicCommand
    def debug_mode_toggle
      DEBUG_FLAG[0] = !DEBUG_FLAG[0]
      puts "Debug mode: #{DEBUG_FLAG[0]}"._colorize(:warning)
      true
    end
  end
end
