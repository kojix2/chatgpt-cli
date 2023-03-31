module Colorize::ObjectExtensions
  ANSI_COLORS = {
    "default"       => 39,
    "black"         => 30,
    "red"           => 31,
    "green"         => 32,
    "yellow"        => 33,
    "blue"          => 34,
    "magenta"       => 35,
    "cyan"          => 36,
    "light_gray"    => 37,
    "dark_gray"     => 90,
    "light_red"     => 91,
    "light_green"   => 92,
    "light_yellow"  => 93,
    "light_blue"    => 94,
    "light_magenta" => 95,
    "light_cyan"    => 96,
    "white"         => 97,
  }

  def _colorize(type)
    c = ChatGPT::Config.instance
    fore = ColorANSI.new(ANSI_COLORS[c.color(type)["fore"]])
    back = ColorANSI.new(ANSI_COLORS[c.color(type)["back"]])
    self.colorize.fore(fore).back(back)
  end

  def _colorize(type, mode)
    raise "No modes other than BOLD have been implemented" if mode != :bold
    _colorize(type).mode(:bold)
  end
end
