module Colorize::ObjectExtensions
  def colorize_warning
    self.colorize(:yellow)
  end

  def colorize_warning_bold
    self.colorize(:yellow).mode(:bold)
  end

  def colorize_chatgpt
    self.colorize(:green)
  end

  def colorize_debug
    self.colorize(:cyan)
  end

  def colorize_stdout
    self.colorize(:yellow)
  end

  def colorize_stderr
    self.colorize(:yellow)
  end
end
