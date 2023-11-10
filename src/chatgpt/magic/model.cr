require "./base"

module ChatGPT
  class Magic
    class Model < Base
      def initialize(sender)
        @sender = sender
        @name = "model"
        @description = "Show model name"
        @patterns = [/\Amodel\z/, /\Amodel\s+(.+)/] # FIXME
      end

      def run
        puts "Model: #{data.model}"._colorize(:warning)
        true
      end

      def run(model_name)
        # FIXME - below code doesn't work. why?
        # data.model = model_name
        # workaround here
        @sender.data.model = model_name
        puts "Set model to #{model_name}"._colorize(:warning)
        true
      end
    end
  end
end
