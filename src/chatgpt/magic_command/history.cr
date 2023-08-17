module ChatGPT
  class MagicCommand
    def show_history
      open_editor(Config::HISTORY_FILE)
      true
    end
  end
end
