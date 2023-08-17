module ChatGPT
  class MagicCommand
    def show_config
      open_editor(Config::CONFIG_FILE)
      true
    end
  end
end
