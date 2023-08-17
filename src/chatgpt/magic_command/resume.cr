module ChatGPT
  class MagicCommand
    def resume
      if File.exists?(Config::POST_DATA_FILE)
        load_data_from_json(Config::POST_DATA_FILE)
      else
        puts "No saved data"._colorize(:warning)
      end
      @total_tokens = -1
      true
    end
  end
end
