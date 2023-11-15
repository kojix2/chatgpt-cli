module Colorize
  module ObjectExtensions
    def _colorize(type)
      config = ChatGPT::Config.instance
      fore = ColorANSI.parse(config.color(type)["fore"])
      back = ColorANSI.parse(config.color(type)["back"])
      self.colorize.fore(fore).back(back)
    end

    def _colorize(type, mode)
      raise "No modes other than BOLD have been implemented" if mode != :bold
      _colorize(type).mode(:bold)
    end
  end
end
