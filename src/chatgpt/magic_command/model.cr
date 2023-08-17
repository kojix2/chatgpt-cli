module ChatGPT
  class MagicCommand
    def show_model_name
      puts "Model: #{data.model}"._colorize(:warning)
      true
    end

    def set_model_name(model_name)
      data.model = model_name
      puts "Set model to #{model_name}"._colorize(:warning)
      true
    end
  end
end
